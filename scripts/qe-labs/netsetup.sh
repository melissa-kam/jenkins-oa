select_sat6_lab1() {
    #SAT6 LAB 01
    SEGID=2010
    GATEWAY_CIDR=10.127.101.128/25
    GATEWAY_IP=10.127.101.129
}

select_iad_lab1() {
    #IAD LAB 01
    SEGID=280
    GATEWAY_CIDR=10.17.255.192/26
    GATEWAY_IP=10.17.255.193
}

select_iad_lab2() {
    #IAD LAB 02
    SEGID=410
    GATEWAY_CIDR=10.4.213.192/26
    GATEWAY_IP=10.4.213.193
}

set_security_inbound_tcp() {
    if [[ `neutron security-group-show default | grep $1 | grep ingress` ]]; then
        echo "Ingress rule for port ($1) already exists!"
        echo "Skipping"
    else
        echo "Creating ingression rule for port ($1)"
        neutron security-group-rule-create --direction ingress --protocol tcp --port-range-min $1 --port-range-max $1 default
    fi
}

set_security_outbound_tcp() {
    if [[ `neutron security-group-show default | grep $1 | grep egress` ]]; then
        echo "Egress rule for port ($1) already exists!"
        echo "Skipping"
    else
        echo "Creating egression rule for port ($1)"
        neutron security-group-rule-create --direction egress --protocol tcp --port-range-min $1 --port-range-max $1 default
    fi
}

set_security_icmp() {
    if [[ `neutron security-group-show default | grep icmp | grep ingress` ]]; then
        echo "Ping ingress rule already exists"
    else
        echo "Creating ping ingression rule"
        neutron security-group-rule-create --direction ingress --protocol icmp default
    fi
}

print_expected_format() {
    echo "Expected format:"
    echo "$0 sat6 lab1"
}

print_parameters() {
    echo $SEGID
    echo $GATEWAY_CIDR
    echo $GATEWAY_IP
    echo "DONE"
}

if [[ $1 == "sat6" ]]; then
    select_sat6_lab1
elif [[ $1 == "iad" && $2 == "lab01" ]]; then
    select_iad_lab1
elif [[ $1 == "iad" && $2 == "lab02" ]]; then
    select_iad_lab2
else
    print_expected_format
    exit
fi

#if [[ `hostname | grep sat6` ]]; then
#    select_sat6_lab1
#elif [[ `hostname | grep iad3 | grep qe1` ]]; then
#    select_iad_lab1
#elif [[ `hostname | grep iad3 | grep qe2` ]]; then
#    select_iad_lab2
#else
#    print_expected_format
#    exit
#fi

print_parameters

neutron net-create public  --provider:network_type=vlan --provider:physical_network=vlan --provider:segmentation_id=$SEGID --router:external=True
neutron net-create private --provider:network_type=vxlan                                 --provider:segmentation_id=1      --router:external=False --shared

neutron subnet-create public  $GATEWAY_CIDR --name public-subnet  --gateway $GATEWAY_IP
neutron subnet-create private 172.31.0.0/24 --name private-subnet --gateway 172.31.0.1 --dns-nameservers list=true 8.8.8.8 8.8.4.4

neutron router-create public-private
neutron router-gateway-set public-private public
neutron router-interface-add public-private private-subnet

set_security_inbound_tcp 22
set_security_outbound_tcp 22
set_security_icmp
