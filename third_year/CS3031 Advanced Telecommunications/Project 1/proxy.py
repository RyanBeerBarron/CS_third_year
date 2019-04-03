import socket, threading, cmd, sys, timeit, datetime
from collections import namedtuple

# CONNECTION CLASS, JUST A STRUCT FOR THE CURRENT THREAD LIST #
class connection:
	def __init__(self, method, host, port):
		self.method = method
		self.host = host
		self.port = port





# MANAGEMENT CONSOLE CLASS, EXTENDS THE CMD CLASS FROM THE CMD MODULE, 	# 
# HAS DIFFERENT COMMAND TO SEE THE STATE OF THE SERVER AND HAD URL TO	#
# THE BLOCKED LIST 														#
class proxyShell(cmd.Cmd):
	intro = "Welcome to the web proxy shell"
	prompt = ">>"


	def do_block(self, args):
		"""Block specified URL"""
		with BLOCK_URL_LOCK:
			BLOCKED_URL.append(args)
			print(args + " is now blocked")

	def do_unblock(self, args):
		"""Unblocks specified URL"""
		with BLOCK_URL_LOCK:
			try:
				BLOCKED_URL.remove(args)
				print(args + " is now unblocked")
			except ValueError:
				print("This URL was not blocked. Can not unblock it.")

	def do_quit(self, args):
		"""End the shell and set END_EVENT thread event to terminate all threads"""
		END_EVENT.set()
		return True

	def do_list(self, args):
		"""List the block URLs"""
		with BLOCK_URL_LOCK:
			for blocked_url in BLOCKED_URL:
				print(f"{blocked_url}\n")

	def do_occupied(self, args):
		"""List the number of free socket"""
		with OCCUPIED_SOCKETS_LOCK:
			total = 0
			for boolean in OCCUPIED_SOCKETS:
				if boolean is True:
					total += 1
			if total is 0:
				print(f"There are no available sockets, sorry")
			elif total is 1:
				print(f"There is one available socket.")
			else:			
				print(f"There are {total} available sockets")		

	def do_current(self, args):
		"""List the busy sockets with their current method, host and port"""
		with CURRENT_CONNECTION_LOCK:
			for i in range(0,MAX_CONNECTION):
				if CURRENT_CONNECTION[i] is not None:
					c = CURRENT_CONNECTION[i]
					print(f"Socket {i} is doing: {c.method} to host {c.host}:{c.port}")

	def do_print(self, args):
		"""Print url present in the cache"""
		with URL_CACHE_LOCK:
			if args in URL_CACHE:
				print(f"{URL_CACHE[args]}")
			else:	
				for key in URL_CACHE:
					print(key)




# LIST OF BLOCKED URLs AND ASSOCIATED LOCK #
BLOCKED_URL = []
BLOCK_URL_LOCK = threading.Lock()

# LIST OF CURRENT SOCKET THREAD AND ASSOCIATED LOCK. USED TO JOIN THE THREAD TO EXIT SAFELY #
CURRENT_THREADS = []
CURRENT_THREADS_LOCK = threading.Lock()


# CACHE, URL IS THE KEY AND VALUE IS A TUPLE CONSISTING OF THE HTTP RESPONSE #
# LAST MODIFIED DATE AND AGE VALUE 											 #
URL_CACHE_LOCK = threading.Lock()
URL_CACHE = {}
url_caching = namedtuple("url_caching", "http_response modified_date age")


# NUMBER OF HTTP REQUEST THE SERVER CAN HANDLE, DOES NOT COUNT SOCKETS USED TO FORWARD THE REQUEST AND 	 #
# HANDLE THE RESPONSES																					 #
MAX_CONNECTION = 20

# LIST OF OCCUPIED SOCKETS AND ASSOCIATED LOCK, HAS LENGTH MAX CONNECTION #
OCCUPIED_SOCKETS = [False] * MAX_CONNECTION
OCCUPIED_SOCKETS_LOCK = threading.Lock()

# LIST OF CURRENT CONNECTIONS AND ASSOCIATED LOCK. USED FOR THE MANAGEMENT CONSOLE TO LIST ALL THE CURRENT SOCKET CONNECTIONS #
CURRENT_CONNECTION = [None] * MAX_CONNECTION
CURRENT_CONNECTION_LOCK = threading.Lock()

# BACKLOG FOR THE SERVER AND BUFFER SIZE FOR THE SOCKETS #
BACKLOG = 10
BUFSIZE = 10000
prSh = proxyShell()

# END EVENT USED FOR QUITTING THE PROGRAM SAFELY, SET WHEN QUIT IS TYPED IN THE MANAGEMENT CONSOLE AND EVERY THREAD CHECKS FOR IT FREQUENTLY #
END_EVENT = threading.Event()


# TAKES A HTTP REQUEST MESSAGE AND RETURN A TUPLE CONTAINING HTTP METHOD, HOST NAME, PORT NUMBER AND THE FULL URL #
def parse_message(message):
	try:
		split_message = message.split('\n')
		method = ""
		host = ""
		port = 0
		header_line = split_message[0].split(' ')
		if "b'" in header_line[0]:
			method = header_line[0]
			method = method[2:]
		url = header_line[1]
		host_pos = url.find("://")
		if host_pos != -1:
			temp = host_pos+3
			url = url[temp:]		
		
		port_pos = url.find(":")
		host_pos = url.find("/")
		if port_pos == -1:
			port = 80
			if(host_pos == -1):
				host = url
			else:
				host = url[:host_pos]
		else:
			port_pos += 1 
			port = int(url[port_pos:])
			if host_pos == -1:
				host = url[:port_pos]
				host = host[:-1]
			else:
				host = url[:host_pos]	
		return (method, host, port, url)
	except IndexError:
		print("Index error occured:")
		print(message)

# TAKES AN HTTP RESPONSE AND RETURN THE RESPONSE CODE AND LAST MODIFIED DATA IF ANY #
def parse_response(response):
	split_response = response.split('\\n')
	response_code = ""
	last_modified = ""
	for lines in split_response:
		split_line = lines.split(" ")
		for field in split_line:
			if "b'" in field:
				field = field[2:]
			if field == "HTTP/1.1":
				response_code = split_line[1]
			if field == "Last-Modified:":
				last_modified = split_line[1:]
	return (response_code, last_modified)		


# MANAGEMENT CONSOLE FUNCTION, MAIN THREAD #
def proxyShellFoo(shell):
	try:
		shell.cmdloop()
	except AttributeError:
		print("This is not a shell, exiting...")
		END_EVENT.set()

# TRANSMIT FUNCTION, USED BY BOTH HTTPS AND HTTP, TAKES THE SOCKET TALKING TO THE SERVER AND THE OTHER SOCKET
# TALKING TO THE CLIENT. RETURNS THE NUMBER OF BYTES TRANSMITTED BY THE SERVER AND THE FULL DATA.
# 
# FUNCTION LISTEN AND TRANSMIT BACK AND FORTH BETWEEN THE FIRST PASSED SOCKET AND THE SECOND ONE
# DEPENDING ON THE METHOD, MIGHT START LISTENING TO THE CLIENT (HTTPS) OR THE SERVER (HTTP), USED FOR PERSISTENT HTTP
# SOCKETS NEED TO HAVE A TIMEOUT SET UP, FREQUENTLY CHECK FOR END EVENT IF USER WANTS TO EXIT
# LISTENS TO THE SOCKETS AND TRANSMIT WHATEVER WAS RECEIVED
# MAKES SURE THE SOCKET TRANSMITTED SOMETHING, IF NOTHING WAS TRANSMITTED, THE TRANSMISSION IS OVER AND FUNCTION WILL RETURN
def transmit(first_socket, second_socket):
	first_socket_con, second_socket_con = True, True
	total_bytes, total_data = 0, ""
	while first_socket_con and second_socket_con:
		if END_EVENT.is_set():
			break
		else:
			hasTransmitted = False
			try:
				while 1:
					data = first_socket.recv(BUFSIZE)
					total_bytes += len(data)
					total_data += str(data)
					if len(data) > 0:
						second_socket.sendall(data)
						hasTransmitted = True
					elif not hasTransmitted:
						first_socket_con = False
						break
					else:
						break	
			except socket.timeout:
				if not hasTransmitted:
					first_socket_con = False
					break
			hasTransmitted = False
			try:
				while 1:
					data = second_socket.recv(BUFSIZE)
					if len(data) > 0:
						hasTransmitted = True
						first_socket.sendall(data)
					elif not hasTransmitted:
						second_socket_con = False
					else:
						break
			except socket.timeout:
				if not hasTransmitted:
					second_socket_con = False
					break
	return(total_bytes, total_data)															
								

# SOCKET THREAD FUNCTION, WHEN THE SERVER RECEIVES A REQUEST, DISPATCH A NEW THREAD WITH THAT FUNCTION
# THE NEW SOCKET WILL RECEIVE THE ACTUAL REQUEST, DECODE IT, CHECK IF THE URL IS BLOCKED OR NOT AND TRANSMIT
# USING THE RIGHT PROTOCOL BY CREATING A NEW SOCKET CONNECTED TO THE SERVER
#
# IF THE METHOD IS HTTPS AND THE SERVER SOCKET SUCCESFULLY CONNECTED, SEND A 200 TO THE CLIENT AND STARTS TO
# TRANSMIT IN TUNNEL MODE BY FIRST LISTENING TO THE CLIENT.
#
# IF THE METHOD IS HTTP, IT CHECKS THE CACHE IF THE URL IS ALREADY PRESENT AND SEND A CONDITIONAL GET
# 	IF THE CACHED VERSION IS FRESH, i.e IT RECEIVES 304, TRANSMIT THE CACHED VERSION TO THE CLIENT
#	IF THE CACHED VERSION IS STALE, i.e IT RECEIVES 200, TRANSMIT THAT RESPONSE AND THEN LISTEN TO CLIENT
#
# IF THE URL IS NOT IN CACHE, JUST SEND THE REQUEST TO THE SERVER AND START TO TRANSMIT BY LISTENING TO
# THE SERVER FIRST
#
# AT THE END, UPDATE CACHE FOR HTTP BY PARSING THE RESPONSE CONTAINING THE ACTUAL BODY, TAKE THE FULL RESPONSE AND LAST MODIFIED DATE 
# AND FOR BOTH METHOD, CLOSE THE SOCKETS AND CLEAN UP.
def socketConnection(client_socket, address, index):
		encoded_message = client_socket.recv(BUFSIZE)
		message = str(encoded_message)	
		method, host, port, url = parse_message(str(encoded_message)) 
		print(f"method: {method}\nhost: {host}\nport: {port}")
		
		c = connection(method, host, port)
		with CURRENT_CONNECTION_LOCK:
			CURRENT_CONNECTION[index] = c
			
		# CHECK IF URL IS BLOCKED #	
		with BLOCK_URL_LOCK:
			for i in BLOCKED_URL:
				if i in host:
					print("Sorry, the website you are trying to access is block\n")
					client_socket.close()
					OCCUPIED_SOCKETS[index] = False
					return

		# CREATE NEW SOCKET FOR SENDING TO SERVER #			
		try:
			server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
			server_socket.connect((host, port))
			s = ""
			if method == "CONNECT":
				s = "HTTPS"
			else:
				s = "HTTP"	
			print(f"New socket from socket {index} connecting to: {host}:{port} with {s}")	
			if host != "tiles.services.mozilla.com":
				print(f"Incoming client request\n{message}")
			total_bytes = 0
			total_data = ""
			clientConnected = True
			serverConnected = True
			client_socket.settimeout(3.0)
			server_socket.settimeout(3.0)
			t0 = timeit.default_timer()

			# HTTPS METHOD #
			if method == "CONNECT":
				httpsSucces = "HTTP/1.1 200 OK\r\n\r\n"
				client_socket.send(httpsSucces.encode())
				total_bytes, total_data = transmit(client_socket, server_socket)
		

			# NORMAL HTTP METHOD #
			else:
				print("Normal HTTP")
				inCache = 0
				last_modified = None
				cached_version = None
				cache_fresh = False
				# CHECK IF IN CACHE #
				with URL_CACHE_LOCK:
					if url in URL_CACHE:
						inCache = 1
						cached_version = URL_CACHE[url]
						last_modified = cached_version.modified_date
				
				server_socket.send(encoded_message)
				response = server_socket.recv(BUFSIZE)
				total_bytes += len(response)
				total_data += str(response)
				response_code, last_modified = parse_response(str(response))
				if response_code == "304" and inCache:
					with URL_CACHE_LOCK:
						cached_version = URL_CACHE[url]
						client_socket.send(cached_version[0].encode())
						total_data = cached_version[0]
						print("Cache succes")
				else:
					client_socket.send(response)
					temp1, temp2 = transmit(client_socket, server_socket)
					total_bytes += temp1
					total_data += temp2
					print("Cache unsuccesful")
				if not response_code == "304":	
					response_code, last_modified = parse_response(str(total_data))
				print(f"The response code is: {response_code} and last modified is: {last_modified}")
				# UPDATE CACHE #
				if responseesponse_code == "200":
					with URL_CACHE_LOCK:
						if not inCache:
							for key in URL_CACHE:
								cached = URL_CACHE[key]
								if cached[2] == 10:
									del URL_CACHE[key]
								else:
									new_cache_entry = url_caching(cached[0], cached[1], cached[2]+1)
									URL_CACHE[key] = new_cache_entry
							newcached = url_caching(total_data, last_modified, 0)
							URL_CACHE[url] = newcached
						elif inCache and cache_fresh:
							cached = URL_CACHE[url]
							temp = cached[2]
							cached[2] = 0
							for key in URL_CACHE:
								if key is not url:
									cached = URL_CACHE[key]
									if cached[2] < temp:
										cached[2] += 1
						elif inCache and not cache_fresh:
							cached = URL_CACHE[url]
							temp = cached[2]
							new_cache_entry = url_caching(total_data, last_modified, 0)
							URL_CACHE[url] = new_cache_entry
							for key in URL_CACHE:
								if key is not url:
									cached = URL_CACHE[key]
									if cached[2] < temp:
										new_cache_entry = url_caching(cached[0], cached[1], cached[2]+1)
										URL_CACHE[key] = new_cache_entry


			# FINISHED, DO SOME PRINTING AND CLOSE SOCKET AND SET SOCKET STATUS AS FREE #
			t1 = timeit.default_timer()
			time = t1 - t0
			print(f'The whole connection from socket {index} to {host}:{port}, using {method} transmitted {total_bytes} bytes of data in {time} seconds. Bandwith was {total_bytes/time} bytes/sec\n')		
			server_socket.close()
			client_socket.close()
			with CURRENT_CONNECTION_LOCK:
				CURRENT_CONNECTION[index] = None
			with OCCUPIED_SOCKETS_LOCK:
				OCCUPIED_SOCKETS[index] = False
			if not END_EVENT.is_set():
				with CURRENT_THREADS_LOCK:
					CURRENT_THREADS.remove(threading.current_thread())	
			return

		# SOCKET EXCEPTION, CLOSE SOCKETS AND EXIT #
		except (socket.error, socket.gaierror):
			print(f"Could not connect to {host}:{port}")
			if client_socket:
				client_socket.close()	
			if server_socket:
				server_socket.close()	
			with CURRENT_CONNECTION_LOCK:
				CURRENT_CONNECTION[index] = None
			with OCCUPIED_SOCKETS_LOCK:
				OCCUPIED_SOCKETS[index] = False
			if not END_EVENT.is_set():
				with CURRENT_THREADS_LOCK:
					CURRENT_THREADS.remove(threading.current_thread())
			return


# MAIN METHOD, STARTS THE MANAGEMENT CONSOLE AND SET UP THE SOCKET LISTENING TO REQUESTS
# WHEN A CONNECTION IS ACCEPTED, DISPATCH A NEW THREAD TO TAKE CARE OF IT
# 
# ON EXIT, MUST JOIN ALL THE SOCKET THREADS BEFORE EXITING.
if __name__ == "__main__":
	with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
		port = int(input("port number please:\n"))
		s.bind(("", port))
		shellThread = threading.Thread(target= proxyShellFoo, args= [prSh])
		shellThread.start()
		s.listen(BACKLOG)
		s.settimeout(3.0)
		print("Main socket is now listening, ready to accept connections.")
		while 1:
			if END_EVENT.is_set():
				with CURRENT_THREADS_LOCK:
					for i in range(0, len(CURRENT_THREADS)):
						CURRENT_THREADS[i].join()
				s.close()
				print("bye!")
				sys.exit()
			try:
				conn, addr = s.accept()
				with OCCUPIED_SOCKETS_LOCK:
					index = OCCUPIED_SOCKETS.index(False)
					socket_thread = threading.Thread(target= socketConnection, args= [conn, addr, index])
					socket_thread.start()
					OCCUPIED_SOCKETS[index] = True
				with CURRENT_THREADS_LOCK:
					CURRENT_THREADS.append(socket_thread)

			except ValueError:
				print("All sockets are busy, sorry. Try again later.")	
			except socket.timeout:
					pass
		
