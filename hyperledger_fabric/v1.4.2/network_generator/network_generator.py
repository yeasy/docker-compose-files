#!/usr/bin/env python
# Generate Hyperledger Fabric Network docker-compose.yaml files
# base on input parameters
# github.com/yeasy/docker-compose

# tested with version 0.15.3
from ruamel.yaml import YAML
import argparse
import copy
import collections

DOCKER_COMPOSER_VERSION='2.0'
DEFAULT_CONFIG_FILE = 'network_config.json'
PEER_TEMPLATE_FILE = 'peer.yaml'
ORDERER_TEMPLATE_FILE = 'orderer.yaml'
RESULT_FILE = '{}orgs-{}peers-{}.yaml'

# Orderer
# consensus_mode, org_name, node_name
ORDERER_GB_VOLUME = './{}/channel-artifacts/orderer.genesis.block'
ORDERER_GB_PATH = '/var/hyperledger/orderer/orderer.genesis.block'
ORDERER_MSP_VOLUME = './{}/crypto-config/ordererOrganizations/{}/orderers/{}/msp'
ORDERER_TLS_VOLUME = './{}/crypto-config/ordererOrganizations/{}/orderers/{}/tls'
ORDERER_MSP_PATH = '/var/hyperledger/orderer/msp'
ORDERER_TLS_PATH = '/var/hyperledger/orderer/tls'

# PEER
# consensus_mode, org_name, node_name
PEER_MSP_VOLUME = './{}/crypto-config/peerOrganizations/{}/peers/{}/msp'
PEER_TLS_VOLUME = './{}/crypto-config/peerOrganizations/{}/peers/{}/tls'
PEER_MSP_PATH = '/etc/hyperledger/fabric/msp'
PEER_TLS_PATH = '/etc/hyperledger/fabric/tls'


yaml = YAML()
yaml.explicit_start = True


def list_to_dict(l, sep=':'):
    """
    Convert list to dict with order
    :param l: list
    :param sep: separator
    :return: dicted result

    >>> list_to_dict(['a=1','b=2'], '=')
    OrderedDict([('a', '1'), ('b', '2')])
    >>> list_to_dict(['a:1','b:2'])
    OrderedDict([('a', '1'), ('b', '2')])
    """
    result = collections.OrderedDict()
    for x in l:
        k, v = x.split(sep, 2)
        result[k] = v
    return result


def dict_to_list(d, sep=':'):
    """
    Convert the given dict to list
    :param d: dict
    :param sep: separator
    :return:


    >>> dict_to_list({'a': '1', 'b': '2'})
    ['a:1', 'b:2']
    """
    result = list()
    for k,v in d.items():
        result.append('{}{}{}'.format(k, sep, v))
    return result

def parse_args():
    """
    Parse the args
    :return:
    """
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', "--config_file", help="Path to the config file",
                        type=str, default=DEFAULT_CONFIG_FILE)
    args = parser.parse_args()
    print(args.config_file)


def gen_peer(template, org_name, org_msp, node_name, consensus_mode):
    """
    Generate peer for given org and name
    :param template: Template to use
    :param org_name: Name of org,
    :param org_msp: MSP ID of the org,
    :param node_name: Name of the peer
    :param consensus_mode: Mode of consensus
    :return:
    """
    node = copy.deepcopy(template)
    addr = node_name  # e.g., peer0.org1.example.com
    node['container_name'] = addr
    node['hostname'] = addr

    # update environments part
    environment = list_to_dict(node['environment'], '=')
    environment['CORE_PEER_ID'] = addr  # peer id
    environment['CORE_PEER_ADDRESS'] = addr+':7051'  # peer grpc port
    environment['CORE_PEER_CHAINCODELISTENADDRESS'] = addr+':7052'  # chaincode
    environment['CORE_PEER_GOSSIP_EXTERNALENDPOINT'] = addr+':7051'  # gossip
    environment['CORE_PEER_LOCALMSPID'] = org_msp  # org msp name
    node['environment'] = dict_to_list(environment, '=')

    # replace volumes part
    volumes = {
        PEER_MSP_VOLUME.format(consensus_mode, org_name, node_name):
            PEER_MSP_PATH,
        PEER_TLS_VOLUME.format(consensus_mode, org_name, node_name):
            PEER_TLS_PATH,
    }
    node['volumes'] = dict_to_list(volumes, ':')

    return node


def gen_peers(org_name='org1.example.com', org_msp='Org1MSP', num=2,
              consensus_mode='solo'):
    """
    Generate given num peers for Organization org_msp
    :param org_name: Name of the org,
    :param org_msp: MSP of the organization that peer belongs to
    :param num: Number of peer nodes to generate
    :param consensus_mode: Mode of consensus
    :return:
    """
    c = yaml.load(open(PEER_TEMPLATE_FILE, 'r'))
    peer = c['services']['peer']
    result_peers = dict()
    for i in range(num):
        name = 'peer{}.{}'.format(i, org_name)  # peer0.org1.example.com
        result_peers[name] = gen_peer(peer, org_name, org_msp, name,
                                      consensus_mode)
    return result_peers


def gen_app_orgs(orgs=2, peers=2, consensus_mode='solo'):
    """
    Generate peer orgs with given number
    :param orgs: Number of app orgs to generate
    :param peers: Peers number for each org
    :param consensus_mode: Mode of consensus
    :return:
    """
    services = dict()
    for i in range(orgs):
        org_name = 'org{}.example.com'.format(i+1)  # match crypto-config.yaml
        org_msp = 'Org{}MSP'.format(i+1)
        services.update(gen_peers(org_name, org_msp, peers, consensus_mode))
    return services


def gen_orderer(template, org_name, node_name, consensus_mode):
    """
    Generate peer for given org and name
    :param template: Template to use
    :param org_name: Name of org,
    :param org_msp: MSP ID of the org,
    :param node_name: Name of the node
    :param consensus_mode: Mode of consensus
    :return:
    """
    node = copy.deepcopy(template)
    addr = node_name  # e.g., orderer0.orderer.example.com
    node['container_name'] = addr
    node['hostname'] = addr

    # replace volumes part
    volumes = {
        ORDERER_GB_VOLUME.format(consensus_mode): ORDERER_GB_PATH,
        ORDERER_MSP_VOLUME.format(consensus_mode, org_name, node_name):
            ORDERER_MSP_PATH,
        ORDERER_TLS_VOLUME.format(consensus_mode, org_name, node_name):
            ORDERER_TLS_PATH,
    }
    node['volumes'] = dict_to_list(volumes, ':')

    return node


def gen_orderers(org_name='orderer.example.com', num=2, consensus_mode='solo'):
    """
    Generate given num peers for Organization org_msp
    :param org_name: Name of the org,
    :param num: Number of peer nodes to generate
    :param consensus_mode: Mode of consensus
    :return:
    """
    try:
        c = yaml.load(open(ORDERER_TEMPLATE_FILE, 'r'))
        orderer = c['services']['orderer-{}'.format(consensus_mode)]
        result_nodes = dict()
        for i in range(num):
            name = 'orderer.example.com'
            #name = 'orderer{}.{}'.format(i, org_name)
            result_nodes[name] = gen_orderer(orderer, org_name, name,
                                             consensus_mode)
        return result_nodes
    except Exception as e:
        print("Failed to gen_orderers with {}:{}".format(PEER_TEMPLATE_FILE, e))
        return dict()


def gen_orderer_orgs(orderers=1, consensus_mode='solo'):
    """
    Generate peer orgs with given number
    :param orderers: Orderers number for each org
    :param consensus_mode: Mode of consensus
    :return:
    """
    services = dict()
    org_name = 'example.com' # match crypto-config.yaml
    services.update(gen_orderers(org_name, orderers, consensus_mode))
    return services


if __name__ == '__main__':
    import doctest
    doctest.testmod()

    parse_args()

    # network topology config
    app_org_num = 2
    app_org_size = 2
    orderer_org_size = 1
    consensus_mode = 'solo'

    network = dict([('version','2.0'), ('services', dict())])
    network['services'].update(gen_orderer_orgs(orderer_org_size,
                                                consensus_mode))
    network['services'].update(gen_app_orgs(app_org_num, app_org_size,
                                            consensus_mode))

    with open(RESULT_FILE.format(app_org_num, app_org_num*app_org_size,
                                 'solo'), 'w') as f:
        yaml.dump(network, f)
