import base64
import binascii
import json
import os
import sys


def decode_if_b64(raw):
	"""
	Decode a string if it's base 64
	:param raw: original bytes
	:return: True, decoded_result or False, Orignal bytes
	"""
	success = False
	result = raw
	try:
		if isinstance(raw, str):
			result = base64.decodebytes(bytes(raw, 'utf-8'))
			success = True
	except binascii.Error:
		success = False

	if success:  # result_bytes = b'xxxx\xx'
		print('===================Start==================================')
		print(raw)
		print(result)
		print('=====================End===================================')
	return success, result


def check_tree(tree, prefix, f_write):
	"""
	Print the tree recursively with given path prefix
	:param tree: the tree to check
	:param prefix: path prefix to the root of this tree
	:param f_write: Which file to write into
	:return:
	"""
	if isinstance(tree, dict):
		for k, v in tree.items():
			prefix_path = prefix + "." + k
			if isinstance(v, dict) or isinstance(v, list):  # continue sub-tree
				check_tree(v, prefix_path, f_write)
			else:  # leaf
				result = v
				if 'cert' in k or 'id_bytes' in k or 'value' in k and 'hash' not in k:
					print(prefix_path)
					success, result = decode_if_b64(v)
					if success:
						result = "b64({})".format(result)
				f_write.write("{}={}\n".format(prefix_path, result))
	elif isinstance(tree, list):
		for i, v in enumerate(tree):
			prefix_path = "{}[{}]".format(prefix, i)
			if isinstance(v, dict) or isinstance(v, list):  # continue sub-tree
				check_tree(v, prefix_path, f_write)
			else:  # leaf
				result = v
				if 'metadata' not in prefix_path:
					success, result = decode_if_b64(v)
					if success:
						print(prefix_path)
						result = "b64({})".format(result)
				f_write.write("{}={}\n".format(prefix_path, result))
	else:  # json only allow dict or list structure
		print("Wrong format of json tree")


def process(directory):
	"""
	Process all json files under the path
	:param directory: Check json files under which directory
	:return:
	"""
	for f in os.listdir(directory):
		if f.endswith(".block.json"):
			file_name = os.path.join(json_dir, f)
			f_read = open(file=file_name, mode="r", encoding='utf-8')
			f_write = open(file=file_name+"-flat.json", mode="w", encoding='utf-8')
			check_tree(json.load(f_read), "", f_write)
			f_read.close()
			f_write.close()
		else:
			print("Ignore non-json file {}".format(f))


# Usage python json_flatter.py [path_containing_json_files]
# Print all json elements in flat structure
# e.g.,
# {
#	"a": {
#       	"b": ["c", "d"]
#		 }
#  }
# ==>
# a.b[0]=c
# a.b[1]=d
if __name__ == '__main__':
	json_dir = "../raft/channel-artifacts/"
	if len(sys.argv) > 1:
		json_dir = sys.argv[1]

	print("Will process json files under {}".format(json_dir))
	process(json_dir)
