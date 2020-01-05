open Core
open Async

(* 

Connection handler should concurrently:
1) read from socket and print to console and write to socket "ACK"
2) read from stdin and write to socket
we need: socket reader + stdin reader + socket writer

*)

(*
Calculate RTT: 
1) everytime we write to w, enqueue system time to Q
2) everytime we read from r a "msg recved", dequeue from Q subtract from curr_sys_time

*)
let flt_of_fltoption = function 
	| None -> 0.0 
	| Some n -> n;;

let conn_handler _ r w =
	let queue = Queue.create () in
	let stdin = Lazy.force Reader.stdin in
	let rec stdin_to_w () =
		Reader.read_line stdin >>= function
		| `Eof -> return ()
		| `Ok usr_input ->
			Writer.write_line w usr_input;
			let curr_t = Unix.gettimeofday() in
			Queue.enqueue queue curr_t;
			stdin_to_w ()
	in
	let rec r_to_stdout () =
		Reader.read_line r >>= function
		| `Eof  -> return ()
		| `Ok "exit" -> return ()
		| `Ok "Message Received." -> 
			let curr_t = Unix.gettimeofday() in
			let prev_t = flt_of_fltoption (Queue.dequeue queue) in
			let rtt = curr_t -. prev_t in
			printf "Message Received. RTT: %fs\n" rtt;
			r_to_stdout ()
		| `Ok usr_input ->
			printf "%s\n" usr_input;
			Writer.write_line w "Message Received.";
			r_to_stdout ()
	in
	Deferred.any [stdin_to_w (); r_to_stdout ()]

let start_client a p =
	Tcp.with_connection
	(Tcp.Where_to_connect.of_host_and_port { host = a; port = p})
	(fun sock reader writer ->
		printf "client connected to %s at port %d...\n" a p;
		conn_handler sock reader writer)

let start_server p = 
	printf "Server listening on port %d...\n" p;
	let host_and_port =
		Tcp.Server.create
		~on_handler_error:`Raise
		(Tcp.Where_to_listen.of_port p)
		(fun sock reader writer ->
			conn_handler sock reader writer)
	in
	ignore (host_and_port : (Socket.Address.Inet.t, int) Tcp.Server.t Deferred.t);
	Deferred.never ()
	
let main ~m ~a ~p =
	match m with
	| "client" -> start_client a p
	| "server" -> start_server p
	| _ -> printf "Invalid Mode\n"; Deferred.unit

let () = 
	Command.async_spec
		~summary:"One-to-One Chat over TCP"
		Command.Spec.(
			empty
			+> flag "-m" (required string)
				~doc: "start application in server or client mode"
			+> flag "-a" (optional_with_default "localhost" string) 
				~doc: "ip address for client to connect to (default localhost)"
			+> flag "-p" (optional_with_default 12345 int)
				~doc:" Port to listen on (default 12345)"
		)
		(fun m a p () -> main ~m ~a ~p)
	|> Command.run
