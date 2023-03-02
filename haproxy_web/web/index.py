#!/usr/bin/python
# authors: yeasy.github.com
# date: 2013-07-05
# update: 2023-03-02


from collections import OrderedDict
from datetime import datetime
import fcntl
from http.server import HTTPServer, SimpleHTTPRequestHandler
import pickle
import socket
import struct


class HandlerClass(SimpleHTTPRequestHandler):
	def get_ip_address(self, ifname):
		"""
		Get the IP from the network interface
		"""
		with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
			return socket.inet_ntoa(fcntl.ioctl(
				s.fileno(),
				0x8915,  # SIOCGIFADDR
				struct.pack('256s', ifname[:15].encode())
			)[20:24])

	def log_message(self, format, *args):
		"""
		Generate the index.html
		"""
		try:
			request = pickle.load(open("pickle_data.txt", "rb"))
		except:
			request = OrderedDict()
		if len(args) < 3 or "200" not in args[1]:
			return

		try:
			time_now = datetime.now()
			ts = time_now.strftime('%H:%M:%S')
			host = self.address_string()
			addr_pair = (host, self.get_ip_address('eth0'))
			if addr_pair not in request:
				request[addr_pair] = [1, ts]
			else:
				num = request[addr_pair][0] + 1
				del request[addr_pair]
				request[addr_pair] = [num, ts]
			file = open("index.html", "w")
			file.write(
				"<!DOCTYPE html> <html> <body><center><h1><font color=\"blue\" face=\"Georgia, Arial\" size=8><em>HA</em></font> Webpage Visit Results</h1>")
			for pair in request:
				if pair[0] == host:
					guest = "LOCAL: " + pair[0]
				else:
					guest = pair[0]
				if (time_now - datetime.strptime(request[pair][1],
				                                 '%H:%M:%S')).seconds < 3:
					file.write("<p style=\"font-size:150%\" >" + str(
						request[pair][1]) + ": <font color=\"red\">" + str(
						request[pair][
							0]) + "</font> requests " + "from &lt;<font color=\"blue\">" + guest + "</font>>&nbsp;to WebServer &lt;<font color=\"blue\">" +
					           pair[1] + "</font>>&nbsp;</p>")
				else:
					file.write("<p style=\"font-size:150%\" >" + str(
						request[pair][1]) + ": <font color=\"maroon\">" + str(
						request[pair][
							0]) + "</font> requests " + "from &lt;<font color=\"navy\">" + guest + "</font>>&nbsp;to WebServer &lt;<font color=\"navy\">" +
					           pair[1] + "</font>>&nbsp;</p>")
			file.write("</center></body> </html>")
			file.close()
			with open('pickle_data.txt', 'wb') as handle:
				pickle.dump(request, handle, protocol=pickle.HIGHEST_PROTOCOL)
		except Exception as e:
			print("Error:", e)


if __name__ == '__main__':
	try:
		httpd = HTTPServer(('0.0.0.0', 80), HandlerClass)

		print("serving at port", 80)
		httpd.serve_forever()
	except Exception as e:
		print("Error:", e)
		exit(1)
