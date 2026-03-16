

class Node(object):
    """
    Node is a base class, representing a peer/orderer/ca in the network
    """

    def __init__(self, org, name):
        """

        :param org: which org it belongs to
        :param name: name of the node
        """
        self.org = org
        self.name = name
