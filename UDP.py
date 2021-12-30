# Program for testing UDP connectivity

import socket
import sys

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(("", int(input("Listen on port: "))))
sock.settimeout(1.0)


while True:
	cmd = input("Enter command. recv or send. ")
	if cmd == 'recv':
		try:
		    data, addr = sock.recvfrom(1024)
		    print("received message:",data, 'from', addr)
		except socket.timeout:
			print("timeout")
	elif cmd == 'send':
		sock.sendto(input("Message: ").encode('UTF-8'), (input('ip: '), int(input("port: "))))
	else:
		print("what")
