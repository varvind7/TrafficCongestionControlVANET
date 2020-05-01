#---------------------------------Greedy Perimeter Stateless Routing (GPSR)------------------------


proc readoverall { } {

global s d node ns sink
set ii 0
set p1_ii 0
set p2_ii 0
set p3_ii 0


#open overall and store in array
set ov [open overall r]
set x($ii) $s
incr ii
while { [gets $ov data] >= 0 } {
set x($ii) $data
incr ii }
close $ov
set x($ii) $d
incr ii


#open CAR1 and store in array
set p1 [open path1 r]

while { [gets $p1 data] >= 0 } {
set p1_x($p1_ii) $data
incr p1_ii }
close $p1


#open CAR2 and store in array
set p2 [open path2 r]

while { [gets $p2 data] >= 0 } {
set p2_x($p2_ii) $data
set p2_ii [expr $p2_ii +1] }
close $p2

#open CAR3 and store in array
set p3 [open path3 r]

while { [gets $p3 data] >= 0 } {
set p3_x($p3_ii) $data
set p3_ii [expr $p3_ii +1] }
close $p3

#open CAR4 and store in array
set p4 [open path4 r]

while { [gets $p4 data] >= 0 } {
set p4_x($p4_ii) $data
set p4_ii [expr $p4_ii +1] }
close $p4

set rr 0
  #move path from overloaded CH to load balancing path between source and destination (if source and destination are shortest path)
if {$rr == 0 } { 

  #adding GPSR protocol to find the vehicle nearer
Agent/GPSR set bdesync_                0.5 ;
Agent/GPSR set bexp_                   [expr 3*([Agent/GPSR set bint_]+[Agent/GPSR set bdesync_]*[Agent/GPSR set bint_])] ;
Agent/GPSR set pint_                   1.5 ;
Agent/GPSR set pdesync_                0.5 ;
Agent/GPSR set lpexp_                  8.0 ;
Agent/GPSR set drop_debug_             1   ;
Agent/GPSR set peri_proact_            1 	 ;
Agent/GPSR set use_implicit_beacon_    1   ;
Agent/GPSR set use_timed_plnrz_        0   ;
Agent/GPSR set use_congestion_control_ 0
Agent/GPSR set use_reactive_beacon_    0   ;

set val(bint)           0.5  ;# beacon interval
set val(use_mac)        1    ;# use link breakage feedback from MAC
set val(use_peri)       1    ;# probe and use perimeters
set val(use_planar)     1    ;# planarize graph
set val(verbose)        1    ;#
set val(use_beacon)     1    ;# use beacons at all
set val(use_reactive)   0    ;# use reactive beaconing
set val(locs)           0    ;# default to OmniLS
set val(use_loop)       0    ;# look for unexpected loops in peris

set val(agg_mac)          1 ;# Aggregate MAC Traces
set val(agg_rtr)          0 ;# Aggregate RTR Traces
set val(agg_trc)          0 ;# Shorten Trace File


set val(chan)		Channel/WirelessChannel
set val(prop)		Propagation/TwoRayGround
set val(netif)		Phy/WirelessPhy
set val(mac)		Mac/802_11
set val(ifq)		Queue/DropTail/PriQueue
set val(ll)		LL
set val(ant)		Antenna/OmniAntenna
set val(x)		1366      ;# X dimension of the topography
set val(y)		1000      ;# Y dimension of the topography
set val(ifqlen)		50       ;# max packet in ifq
set val(seed)		1.0
set val(adhocRouting)	GPSR      ;# AdHoc Routing Protocol
set val(nn)		18       ;# how many nodes are simulated
set val(stop)		8.0     ;# simulation time
set val(use_gk)		0	  ;# > 0: use GridKeeper with this radius
set val(zip)		0         ;# should trace files be zipped

set val(agttrc)         ON ;# Trace Agent
set val(rtrtrc)         ON ;# Trace Routing Agent
set val(mactrc)         ON ;# Trace MAC Layer
set val(movtrc)         ON ;# Trace Movement


set val(lt)		""
set val(cp)		"cp-n40-a40-t40-c4-m0"
set val(sc)		"sc-x2000-y2000-n40-s25-t40"

set val(out)            "out.tr"

Agent/GPSR set locservice_type_ 3

add-all-packet-headers
remove-all-packet-headers
add-packet-header Common Flags IP LL Mac Message GPSR  LOCS SR RTP Ping HLS

Agent/GPSR set bint_                  $val(bint)
# Recalculating bexp_ here
Agent/GPSR set bexp_                 [expr 3*([Agent/GPSR set bint_]+[Agent/GPSR set bdesync_]*[Agent/GPSR set bint_])] ;# beacon timeout interval
Agent/GPSR set use_peri_              $val(use_peri)
Agent/GPSR set use_planar_            $val(use_planar)
Agent/GPSR set use_mac_               $val(use_mac)
Agent/GPSR set use_beacon_            $val(use_beacon)
Agent/GPSR set verbose_               $val(verbose)
Agent/GPSR set use_reactive_beacon_   $val(use_reactive)
Agent/GPSR set use_loop_detect_       $val(use_loop)

CMUTrace set aggregate_mac_           $val(agg_mac)
CMUTrace set aggregate_rtr_           $val(agg_rtr)

# seeding RNG
ns-random $val(seed)

# create simulator instance
set ns_		[new Simulator]

set loadTrace  $val(lt)

set topo	[new Topography]
$topo load_flatgrid $val(x) $val(y)

set tracefd	[open $val(out) w]

$ns_ trace-all $tracefd

set chanl [new $val(chan)]

# Create God
set god_ [create-god $val(nn)]

# Attach Trace to God
set T [new Trace/Generic]
$T attach $tracefd
$T set src_ -5
$god_ tracetarget $T




#==================================================================================
#    				 Simulation parameters setup
#==================================================================================

$ns node-config -adhocRouting  $val(rp) \
                -llType        $val(ll) \
                -macType       $val(mac) \
                -ifqType       $val(ifq) \
                -ifqLen        $val(ifqlen) \
                -antType       $val(ant) \
                -propType      $val(prop) \
                -phyType       $val(netif) \
                -channel       $chan \
                -topoInstance  $topo \
                -agentTrace    ON \
                -routerTrace   ON \
                -macTrace      ON \
                -movementTrace ON

############# NODE PARAMETERS  ##############################

set val(adhocRouting)	GPSR      ;# AdHoc Routing Protocol 

}  
}
set val(chan)   Channel/WirelessChannel    ;# channel type
set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)  Phy/WirelessPhy            ;# network interface type
set val(mac)    Mac/802_11                 ;# MAC type
set val(ifq)    Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)     LL                         ;# link layer type
set val(ant)    Antenna/OmniAntenna        ;# antenna model
set val(ifqlen) 50                         ;# max packet in ifq
set val(nn)     18                         ;# number of mobilenodes
set val(rp)     DSDV                       ;# routing protocol
set val(x)      1366                      ;# X dimension of topography
set val(y)      1000                      ;# Y dimension of topography
set val(stop)   8.0                         ;# time of simulation end

set ns [new Simulator]

#Setup topography object
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)

#Open the NS trace file
set tracefile [open out.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open out.nam w]
$ns namtrace-all $namfile
$ns namtrace-all-wireless $namfile $val(x) $val(y)
set chan [new $val(chan)];#Create wireless channel

#===================================
#     Mobile node parameter setup
#===================================
$ns node-config -adhocRouting  $val(rp) \
                -llType        $val(ll) \
                -macType       $val(mac) \
                -ifqType       $val(ifq) \
                -ifqLen        $val(ifqlen) \
                -antType       $val(ant) \
                -propType      $val(prop) \
                -phyType       $val(netif) \
                -channel       $chan \
                -topoInstance  $topo \
                -agentTrace    ON \
                -routerTrace   ON \
                -macTrace      ON \
                -movementTrace ON

#===================================
#        Nodes Definition        
#===================================
#Create 18 nodes
set n0 [$ns node]
$n0 set X_ 401
$n0 set Y_ 800
$n0 set Z_ 0.0
$ns initial_node_pos $n0 05
$n0 color "black"
$ns at 0.0 "$n0 color black"
set n1 [$ns node]
$n1 set X_ 399
$n1 set Y_ 2
$n1 set Z_ 0.0
$ns initial_node_pos $n1 05
$n1 color "black"
$ns at 0.0 "$n1 color black"
set n2 [$ns node]
$n2 set X_ 899
$n2 set Y_ 800
$n2 set Z_ 0.0
$ns initial_node_pos $n2 05
$n2 color "black"
$ns at 0.0 "$n2 color black"
set n3 [$ns node]
$n3 set X_ 899
$n3 set Y_ 1
$n3 set Z_ 0.0
$ns initial_node_pos $n3 05
$n3 color "black"
$ns at 0.0 "$n3 color black"
set n4 [$ns node]
$n4 set X_ 650
$n4 set Y_ 701
$n4 set Z_ 0.0
$ns initial_node_pos $n4 05
$n4 color "black"
$ns at 0.0 "$n4 color black"
set n5 [$ns node]
$n5 set X_ 647
$n5 set Y_ 600
$n5 set Z_ 0.0
$ns initial_node_pos $n5 05
$n5 color "black"
$ns at 0.0 "$n5 color black"
set n6 [$ns node]
$n6 set X_ 644
$n6 set Y_ 400
$n6 set Z_ 0.0
$ns initial_node_pos $n6 05
$n6 color "black"
$ns at 0.0 "$n6 color black"
set n7 [$ns node]
$n7 set X_ 644
$n7 set Y_ 300
$n7 set Z_ 0.0
$ns initial_node_pos $n7 05
$n7 color "black"
$ns at 0.0 "$n7 color black"
set n8 [$ns node]
$n8 set X_ 644
$n8 set Y_ 109
$n8 set Z_ 0.0
$ns initial_node_pos $n8 05
$n8 color "black"
$ns at 0.0 "$n8 color black"
set n9 [$ns node]
$n9 set X_ 643
$n9 set Y_ 25
$n9 set Z_ 0.0
$ns initial_node_pos $n9 05
$n9 color "black"
$ns at 0.0 "$n9 color black"
set n10 [$ns node]
$n10 set X_ 590.183
$n10 set Y_ 354.409
$n10 set Z_ 0.0
$ns initial_node_pos $n10 20
set n11 [$ns node]
$n11 set X_ 590.183
$n11 set Y_ 268.843
$n11 set Z_ 0.0
$ns initial_node_pos $n11 20
set n12 [$ns node]
$n12 set X_ 590.183
$n12 set Y_ 172.987
$n12 set Z_ 0.0
$ns initial_node_pos $n12 20
set n13 [$ns node]
$n13 set X_ 590.183
$n13 set Y_ 76.1321
$n13 set Z_ 0.0
$ns initial_node_pos $n13 20
set n14 [$ns node]
$n14 set X_ 701.602
$n14 set Y_ 810.834
$n14 set Z_ 0.0
$ns initial_node_pos $n14 20
set n15 [$ns node]
$n15 set X_ 701.602
$n15 set Y_ 729.485
$n15 set Z_ 0.0
$ns initial_node_pos $n15 20
set n16 [$ns node]
$n16 set X_ 701.602
$n16 set Y_ 645.063
$n16 set Z_ 0.0
$ns initial_node_pos $n16 20
set n17 [$ns node]
$n17 set X_ 701.602
$n17 set Y_ 566.786
$n17 set Z_ 0.0
$ns initial_node_pos $n17 20


$ns simplex-link $n0 $n1 100.0Mb 10ms DropTail
$ns simplex-link-op $n0 $n1 color yellow
$ns queue-limit $n0 $n1 50
$ns simplex-link $n2 $n3 100.0Mb 10ms DropTail
$ns simplex-link-op $n2 $n3 color yellow
$ns queue-limit $n2 $n3 50
$ns simplex-link $n4 $n5 100.0Mb 10ms DropTail
$ns simplex-link-op $n4 $n5 color white
$ns queue-limit $n4 $n5 50
$ns simplex-link $n6 $n7 100.0Mb 10ms DropTail
$ns simplex-link-op $n6 $n7 color white
$ns queue-limit $n6 $n7 50
$ns simplex-link $n8 $n9 100.0Mb 10ms DropTail
$ns simplex-link-op $n8 $n9 color white
$ns queue-limit $n8 $n9 50


#===================================
#        node label        
#===================================


$ns at 0.00 "$n10 label CAR1"         
$ns at 0.00 "$n11 label CAR2"                    
$ns at 0.00 "$n12 label CAR3"
$ns at 0.00 "$n13 label CAR4"
$ns at 0.00 "$n14 label CAR5"
$ns at 0.00 "$n15 label CAR6"
$ns at 0.00 "$n16 label CAR7"
$ns at 0.00 "$n17 label CAR8"



$ns at 0.4 "$n10 setdest 588.111 563.714 50.0"
$ns at 0.4 "$n11 setdest 588.111 457.424 50.0"
$ns at 0.4 "$n12 setdest 588.111 344.99 50.0"
$ns at 0.4 "$n13 setdest 588.111 239.846 50.0"
$ns at 0.4 "$n14 setdest 689.169 541.432 85.0"
$ns at 0.4 "$n15 setdest 689.169 422.781 85.0"
$ns at 0.4 "$n16 setdest 689.169 346.644 85.0"
$ns at 0.4 "$n17 setdest 689.169 260.083 85.0"


##### FINDING SHORTEST PATH FOR DATA TRANSMISSION #######################

# Defining a transport agent for sending
set tcp0 [new Agent/TCP]

# Attaching transport agent to sender node
$ns attach-agent $n10 $tcp0

# Defining a transport agent for receiving
set sink0 [new Agent/TCPSink]

# Attaching transport agent to receiver node
$ns attach-agent $n11 $sink0

#Connecting sending and receiving transport agents
$ns connect $tcp0 $sink0

#Defining Application instance
set ftp0 [new Application/FTP]

# Attaching transport agent to application agent
$ftp0 attach-agent $tcp0

# Setting flow color
$tcp0 set fid_ 4

# data packet generation starting time
$ns at 3.06 "$ftp0 start"

# data packet generation ending time
$ns at 7.30 "$ftp0 stop"


set tcp [new Agent/TCP]
$tcp set class_ 1
Agent/TCP set packetSize_ 512
Agent/TCP set interval_  0.05
set sink [new Agent/TCPSink]
$ns attach-agent $n11 $tcp
$ns attach-agent $n12 $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 3.46 "$ftp start"
$ns at 7.40 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
Agent/TCP set packetSize_ 512
Agent/TCP set interval_  0.05
set sink [new Agent/TCPSink]
$ns attach-agent $n12 $tcp
$ns attach-agent $n13 $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 3.56 "$ftp start"
$ns at 7.50 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
Agent/TCP set packetSize_ 512
Agent/TCP set interval_  0.05
set sink [new Agent/TCPSink]
$ns attach-agent $n14 $tcp
$ns attach-agent $n15 $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 3.56 "$ftp start"
$ns at 7.50 "$ftp stop"

set tcp [new Agent/TCP]
$tcp set class_ 1
Agent/TCP set packetSize_ 512
Agent/TCP set interval_  0.05
set sink [new Agent/TCPSink]
$ns attach-agent $n15 $tcp
$ns attach-agent $n16 $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 3.56 "$ftp start"
$ns at 7.50 "$ftp stop"


# Defining a transport agent for sending
set tcp1 [new Agent/TCP]

# Attaching transport agent to sender node
$ns attach-agent $n16 $tcp1

# Defining a transport agent for receiving
set sink1 [new Agent/TCPSink]

# Attaching transport agent to receiver node
$ns attach-agent $n17 $sink1

#Connecting sending and receiving transport agents
$ns connect $tcp1 $sink1

#Defining Application instance
set ftp1 [new Application/FTP]

# Attaching transport agent to application agent
$ftp1 attach-agent $tcp1

# Setting flow color
$tcp1 set fid_ 4

# data packet generation starting time
$ns at 3.56 "$ftp1 start"

# data packet generation ending time
$ns at 7.50 "$ftp1 stop"

#===================================
#        shape of vehicle        
#===================================
  	  

 $ns at 0.00 "$n10 add-mark m2 green hexagon"
 $ns at 0.00 "$n11 add-mark m2 green hexagon"
 $ns at 0.00 "$n12 add-mark m2 green hexagon"
 $ns at 0.00 "$n13 add-mark m2 green hexagon"
 $ns at 0.00 "$n14 add-mark m2 green hexagon"
 
 
 $ns at 0.00 "$n15 add-mark m2 green hexagon"
 $ns at 0.00 "$n16 add-mark m2 green hexagon"
 
 $ns at 0.00 "$n17 add-mark m2 green hexagon"
 $ns at 3.26 "$n10 delete-mark m2"
 $ns at 3.39 "$n10 add-mark m2 red hexagon"
 
 
#===================================
#        Agents Definition        
#===================================

#===================================
#        Applications Definition        
#===================================

#===================================
#        Termination        
#===================================
#Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam out.nam &
    exit 0
}
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "\$n$i reset"
}
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run
