
#===================================
#     Simulation parameters setup
#===================================
set val(chan)   Channel/WirelessChannel    ;# channel type
set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)  Phy/WirelessPhy            ;# network interface type
set val(mac)    Mac/802_11                 ;# MAC type
set val(ifq)    Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)     LL                         ;# link layer type
set val(ant)    Antenna/OmniAntenna        ;# antenna model
set val(ifqlen) 50                         ;# max packet in ifq
set val(nn)     28                        ;# number of mobilenodes
set val(rp)     DSDV                       ;# routing protocol
set val(x)      1551                       ;# X dimension of topography
set val(y)      1000                      ;# Y dimension of topography
set val(stop)   10.0                         ;# time of simulation end
set opt(dataRate)	[expr 1.0*256*8]	;

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
#===================================
#        Initialization        
#===================================
#Create a ns simulator
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

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Topology Creation~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

set topo [new Topography]
$topo load_flatgrid 1551 1000

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
#Create 27 nodes

set n0 [$ns node]
$n0 set X_ 298
$n0 set Y_ 604
$n0 set Z_ 0.0
$ns initial_node_pos $n0 15

set n1 [$ns node]
$n1 set X_ 798
$n1 set Y_ 599
$n1 set Z_ 0.0
$ns initial_node_pos $n1 15

set n2 [$ns node]
$n2 set X_ 798
$n2 set Y_ 900
$n2 set Z_ 0.0
$ns initial_node_pos $n2 15

set n3 [$ns node]
$n3 set X_ 1097
$n3 set Y_ 899
$n3 set Z_ 0.0
$ns initial_node_pos $n3 15

set n4 [$ns node]
$n4 set X_ 1097
$n4 set Y_ 602
$n4 set Z_ 0.0
$ns initial_node_pos $n4 15

set n5 [$ns node]
$n5 set X_ 1598
$n5 set Y_ 600
$n5 set Z_ 0.0
$ns initial_node_pos $n5 15

set n6 [$ns node]
$n6 set X_ 1098
$n6 set Y_ 299
$n6 set Z_ 0.0
$ns initial_node_pos $n6 15

set n7 [$ns node]
$n7 set X_ 795
$n7 set Y_ 299
$n7 set Z_ 0.0
$ns initial_node_pos $n7 15

set n8 [$ns node]
$n8 set X_ 297
$n8 set Y_ 302
$n8 set Z_ 0.0
$ns initial_node_pos $n8 15

set n9 [$ns node]
$n9 set X_ 1597
$n9 set Y_ 299
$n9 set Z_ 0.0
$ns initial_node_pos $n9 15

set n10 [$ns node]
$n10 set X_ 801
$n10 set Y_ 0
$n10 set Z_ 0.0
$ns initial_node_pos $n10 15

set n11 [$ns node]
$n11 set X_ 1099
$n11 set Y_ 2
$n11 set Z_ 0.0
$ns initial_node_pos $n11 15

set n12 [$ns node]
$n12 set X_ 868.835
$n12 set Y_ 860.158
$n12 set Z_ 0.0
$ns initial_node_pos $n12 40
set n13 [$ns node]
$n13 set X_ 868.503
$n13 set Y_ 622.344
$n13 set Z_ 0.0
$ns initial_node_pos $n13 40
set n14 [$ns node]
$n14 set X_ 482.333
$n14 set Y_ 362.838
$n14 set Z_ 0.0
$ns initial_node_pos $n14 40
set n15 [$ns node]
$n15 set X_ 350.666
$n15 set Y_ 359.004
$n15 set Z_ 0.0
$ns initial_node_pos $n15 40
set n16 [$ns node]
$n16 set X_ 612.256
$n16 set Y_ 362.213
$n16 set Z_ 0.0
$ns initial_node_pos $n16 40
set n17 [$ns node]
$n17 set X_ 733.698
$n17 set Y_ 444.183
$n17 set Z_ 0.0
$ns initial_node_pos $n17 40
set n18 [$ns node]
$n18 set X_ 947
$n18 set Y_ 462
$n18 set Z_ 0.0
$ns initial_node_pos $n18 40
set n19 [$ns node]
$n19 set X_ 1048.32
$n19 set Y_ 91.1798
$n19 set Z_ 0.0
$ns initial_node_pos $n19 40
set n20 [$ns node]
$n20 set X_ 1258.02
$n20 set Y_ 547.291
$n20 set Z_ 0.0
$ns initial_node_pos $n20 40
set n21 [$ns node]
$n21 set X_ 1405.33
$n21 set Y_ 539.85
$n21 set Z_ 0.0
$ns initial_node_pos $n21 40
set n22 [$ns node]
$n22 set X_ 1541.9
$n22 set Y_ 539.524
$n22 set Z_ 0.0
$ns initial_node_pos $n22 40
set n23 [$ns node]
$n23 set X_ 1201.33
$n23 set Y_ 714.466
$n23 set Z_ 0.0
$ns initial_node_pos $n23 40
set n24 [$ns node]
$n24 set X_ 1481.82
$n24 set Y_ 718.301
$n24 set Z_ 0.0
$ns initial_node_pos $n24 75
set n25 [$ns node]
$n25 set X_ 748.021
$n25 set Y_ 181.668
$n25 set Z_ 0.0
$ns initial_node_pos $n25 40
set n26 [$ns node]
$n26 set X_ 1047.45 
$n26 set Y_ 197.339 
$n26 set Z_ 0.0
$ns initial_node_pos $n26 40
set n27	 [$ns node]
$n27 set X_ 1048.32
$n27 set Y_ 21.1798
$n27 set Z_ 0.0
$ns initial_node_pos $n27 40




$ns simplex-link $n0 $n1 100.0Mb 10ms DropTail
$ns simplex-link-op $n0 $n1 color yellow
$ns queue-limit $n0 $n1 50
$ns simplex-link $n1 $n2 100.0Mb 10ms DropTail
$ns simplex-link-op $n1 $n2 color yellow
$ns queue-limit $n1 $n2 50
$ns simplex-link $n3 $n4 100.0Mb 10ms DropTail
$ns simplex-link-op $n3 $n4 color yellow
$ns queue-limit $n3 $n4 50
$ns simplex-link $n4 $n5 100.0Mb 10ms DropTail
$ns simplex-link-op $n4 $n5 color yellow
$ns queue-limit $n4 $n5 50
$ns simplex-link $n7 $n8 100.0Mb 10ms DropTail
$ns simplex-link-op $n7 $n8 color yellow
$ns queue-limit $n7 $n8 50
$ns simplex-link $n7 $n10 100.0Mb 10ms DropTail
$ns simplex-link-op $n7 $n10 color yellow
$ns queue-limit $n7 $n10 50
$ns simplex-link $n6 $n11 100.0Mb 10ms DropTail
$ns simplex-link-op $n6 $n11 color yellow
$ns queue-limit $n6 $n11 50
$ns simplex-link $n6 $n9 100.0Mb 10ms DropTail
$ns simplex-link-op $n6 $n9 color yellow
$ns queue-limit $n6 $n9 50

$ns at 0.4 "$n13 setdest 874.501 47.0782 200.0"
$ns at 0.4 "$n15 setdest 764.288 370.336 50.0"
$ns at 0.4 "$n14 setdest 764.288 370.336 75.0"
$ns at 0.4 "$n16 setdest 764.288 370.336 200.0"
$ns at 0.4 "$n12 setdest 868.835 616.517 200.0"
$ns at 0.4 "$n20 setdest 1122.03 542.683 200.0"
$ns at 0.4 "$n21 setdest 1122.03 542.683 75.0"
$ns at 0.4 "$n22 setdest 1122.03 542.683 50.0"
$ns at 0.4 "$n19 setdest 1048.32 195.991 100.0"
$ns at 0.4 "$n27 setdest 1048.32 123.991 100.0"
$ns at 0.4 "$n26 setdest 1048.32 267.991 100.0"
$ns at 3.7 "$n15 setdest 1400.7 359.004 150.0"
$ns at 3.7 "$n14 setdest 1467.7 359.004 150.0"
$ns at 3.7 "$n16 setdest 1537.7 359.004 200.0"
$ns at 7.7 "$n12 setdest 874.501 47.0782 200.0"
$ns at 3.7 "$n21 setdest 485.6 545.516 125.0"
$ns at 3.2 "$n20 setdest 433.6 545.516 200.0"
$ns at 3.4 "$n22 setdest 433.6 545.516 50.0"
$ns at 5.4 "$n19 setdest 1000.158 195.991 200.0"
$ns at 5.4 "$n27 setdest 1000.158 123.991 100.0"
$ns at 7.4 "$n19 setdest 1000.529 764.036 200.0"
$ns at 7.4 "$n27 setdest 1000.32 664.036 200.0"


source ./vehicle

#===================================
#        node label        
#===================================

                      
$ns at 0.07 "$n13 label CAR10"
$ns at 0.07 "$n14 label CAR5"                           
$ns at 0.07 "$n16 label CAR6"          
$ns at 0.07 "$n17 label IDS"
$ns at 0.07 "$n18 label RSU" 
$ns at 0.07 "$n20 label CAR8"                          
$ns at 0.07 "$n22 label CAR9"
$ns at 0.07 "$n23 label RSU"         
$ns at 0.07 "$n24 label RSU(TA)"                    
$ns at 0.07 "$n25 label RSU"
$ns at 0.07 "$n26 label CAR7"
$ns at 0.07 "$n15 label CAR1"
$ns at 0.07 "$n12 label CAR2"
$ns at 0.07 "$n19 label CAR3"
$ns at 0.07 "$n21 label CAR4"
$ns at 0.07 "$n27 label CAR11"
$ns at 5.00 "$n26 label Accident"



#---------------------------------ROAD SIDE UNIT (RSU)------------------------


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

  for { set dd 0 } { $dd < $p1_ii } {incr dd } {
	if { $p1_x($dd) == $ne_nd } {
		for {set k 0 } {$k <$p1_ii } {incr k} {
			if { $p1_x($k) == $sne_nd } {
			   set rr 1
			   set p 1
			}
		}
	}    
  }
  for { set dd 0 } {$dd<$p2_ii } {incr dd } {
	if { $p2_x($dd) == $ne_nd } {
		for {set k 0 } {$k <$p2_ii } {incr k} {
			if { $p2_x($k) == $sne_nd } {
			   set rr 1
			   set p 2
			}
		}
	}    
  }
  for { set dd 0 } {$dd<$p3_ii } {incr dd } {
	if { $p3_x($dd) == $ne_nd } {
		for {set k 0 } {$k <$p3_ii } {incr k} {
			if { $p3_x($k) == $sne_nd } {
			   set rr 1
			   set p 3
			}
		}
	}    
  }
   if { $rr == 1 } {
    set xx [expr int([$node($ne_nd) set X_])]
    set yy [expr int([$node($ne_nd) set Y_])]
  
    set nx [expr int([$node($sne_nd) set X_])]
    set ny [expr int([$node($sne_nd) set Y_])] 
  
    set xz [expr int(($nx + $xx)/2)]
    set yz [expr int(($ny + $yy)/2)]


    set de [expr int(sqrt(pow(($xx-$nx),2)+pow(($yy-$ny),2)))]
    if { $de <= 250 } { 
    $ns at 6.9 "$node(21) setdest $xz   $yz   [expr 5*$min]"

   if { $sne_nd == $s || $ne_nd== $s} {
    set jcbr [attach-CBR-traffic $node($sne_nd) $sink($ne_nd) 8 0.001]
    $ns at 7.15 "$jcbr start"
    $ns at 7.16 "$jcbr stop"
    } elseif { $sne_nd == $d || $ne_nd== $d} {
    set jcbr [attach-CBR-traffic $node($sne_nd) $sink($ne_nd) 8 0.001]
    $ns at 8.17 "$jcbr start"
    $ns at 8.18 "$jcbr stop"
    } else {
    set jcbr [attach-CBR-traffic $node($sne_nd) $sink($ne_nd) 8 0.001]
    $ns at 9.16 "$jcbr start"
    $ns at 9.17 "$jcbr stop"
  }
    return $p
    } else { set rr 0 }
  }
}
}
 
     

#===================================
#        shape of vehicle        
#===================================
  	  

 $ns at 0.38 "$n12 add-mark m2 brown hexagon"
 $ns at 0.38 "$n13 add-mark m2 brown hexagon"
 $ns at 0.38 "$n14 add-mark m2 brown hexagon"
 $ns at 0.38 "$n15 add-mark m2 brown hexagon"
 $ns at 0.38 "$n16 add-mark m2 brown hexagon"
 
 
 $ns at 0.38 "$n17 add-mark m2 blue circle"
 $ns at 0.38 "$n18 add-mark m2 orange circle"
 
 $ns at 0.38 "$n19 add-mark m2 brown hexagon"
 $ns at 0.38 "$n20 add-mark m2 brown hexagon"
 
 $ns at 0.38 "$n21 add-mark m2 brown hexagon"
 $ns at 0.38 "$n22 add-mark m2 brown hexagon"
 

$ns at 0.38 "$n27 add-mark m2 brown hexagon"
 
 $ns at 0.38 "$n23 add-mark m2 blue circle"
 $ns at 0.38 "$n24 add-mark m2 green circle"

 $ns at 0.38 "$n25 add-mark m2 blue circle"
 
 $ns at 0.38 "$n26 add-mark m2 brown hexagon"
  
 $ns at 4.98 "$n26 delete-mark m2"
  
 $ns at 5.00 "$n26 add-mark m2 red hexagon"

 $ns at 5.38 "$n19 delete-mark m2"
 $ns at 5.40 "$n19 add-mark m2 blue hexagon"
 $ns at 5.38 "$n27 delete-mark m2"
$ns at 5.40 "$n27 add-mark m2 blue hexagon"
 $ns at 5.38 "$n25 delete-mark m2"
$ns at 5.40 "$n25 add-mark m2 green hexagon"
#————Data Transfer between Nodes—————-#


set tcp [new Agent/TCP]
$tcp set class_ 1
Agent/TCP set packetSize_ 512
Agent/TCP set interval_  0.05
set sink [new Agent/TCPSink]
$ns attach-agent $n26 $tcp
$ns attach-agent $n25 $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 3.46 "$ftp start"
$ns at 7.40 "$ftp stop"



#Setup a UDP connection
set udp [new Agent/UDP]
$ns attach-agent $n15 $udp
set null [new Agent/Null]
$ns attach-agent $n23 $null
$ns connect $udp $null
$udp set fid_ 2

#Setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 1mb
$cbr set random_ false


#Schedule events for the CBR and FTP agents
$ns at 2.1 "$cbr start"


#Setup a UDP connection
set udp [new Agent/UDP]
$ns attach-agent $n19 $udp
set null [new Agent/Null]
$ns attach-agent $n23 $null
$ns connect $udp $null
$udp set fid_ 2

#Setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 1mb
$cbr set random_ false


#Schedule events for the CBR and FTP agents
$ns at 3.1 "$cbr start"


#Setup a UDP connection
set udp [new Agent/UDP]
$ns attach-agent $n12 $udp
set null [new Agent/Null]
$ns attach-agent $n23 $null
$ns connect $udp $null
$udp set fid_ 2

#Setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 1mb
$cbr set random_ false


#Schedule events for the CBR and FTP agents
$ns at 4.1 "$cbr start"


#Setup a UDP connection
set udp [new Agent/UDP]
$ns attach-agent $n21 $udp
set null [new Agent/Null]
$ns attach-agent $n23 $null
$ns connect $udp $null
$udp set fid_ 2

#Setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 1mb
$cbr set random_ false


#Schedule events for the CBR and FTP agents
$ns at 5.1 "$cbr start"


#Setup a UDP connection
set udp [new Agent/UDP]
$ns attach-agent $n24 $udp
set null [new Agent/Null]
$ns attach-agent $n21 $null
$ns connect $udp $null
$udp set fid_ 2

#Setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 1mb
$cbr set random_ false


#Schedule events for the CBR and FTP agents
$ns at 1.1 "$cbr start"


#Setup a UDP connection
set udp [new Agent/UDP]
$ns attach-agent $n23 $udp
set null [new Agent/Null]
$ns attach-agent $n21 $null
$ns connect $udp $null
$udp set fid_ 2

#Setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 1mb
$cbr set random_ false


#Schedule events for the CBR and FTP agents
$ns at 1.1 "$cbr start"

#Setup a UDP connection
set udp [new Agent/UDP]
$ns attach-agent $n26 $udp
set null [new Agent/Null]
$ns attach-agent $n19 $null
$ns connect $udp $null
$udp set fid_ 2

#Setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 1mb
$cbr set random_ false


#Schedule events for the CBR and FTP agents
$ns at 5.2 "$cbr start"
# Tcl program to encrpyt and decrypt a file using RSA

# initialize the parameters for RSA algorithm
#set e 3
#set d 11787
#set n 17947

set e 3
set d 2011
set n 3127
# accept the user's choice
puts "Enter 'E' to encrpyt or 'D' to decrypt"
set choice [gets stdin]
set choice [string toupper $choice]
if {$choice eq "E"} {

# accept the name of the file to encrypt from the user
puts "Enter the absolute path of the file to be encrypted :\t"
set fname [gets stdin]
puts "ENCRYPTION IN PROGRESS ......"
set new [split $fname {.}]
set newfile [lindex $new 0]

# open the file in read mode
set fileid1 [open $fname r]

# open another file in write mode
append newfile "Encryption"
set fileid2 [open $newfile w]

# read the input file
set cont [read $fileid1]
close $fileid1

#split the file contents into constituent characters
set mylist [split $cont {}]

# process character-wise and encrypt
foreach {char} $mylist {
	set asc [scan $char %c] ; # scan command here is used to convert char to ascii
	set res 1
	for {set i 1} {$i <= $e} {incr i} {
		set res [expr "($res * $asc) % $n"]
	}
	set newchar [format "%c" $res]
	puts -nonewline $fileid2 $newchar
}
close $fileid2
puts "ENCRYPTION COMPLETE ......"
}


if {$choice eq "D"} {
# Tcl program to decrpyt a file using RSA 

#p=173
#q=149
# initialize the parameters for RSA algorithm
#set e 3
#set d 11787
#set n 17947

set e 3
set d 2011
set n 3127

# accept file name to decrypt
puts "Enter the absolute path of the file to be decrypted :\t"
set fname [gets stdin]
puts "DECRYPTION IN PROGRESS ......"
set new [split $fname {.}]
set newfile [lindex $new 0] 


# open the file in read mode
set fileid1 [open $fname r]

# open another file in write mode
append newfile "Decryption"
set fileid2 [open $newfile w]

# read the input file
set cont [read $fileid1]
close $fileid1

#split the file contents into constituent characters
set mylist [split $cont {}]

# process character-wise
foreach {char} $mylist {
	if {$char eq ""} {break}
	set asc [scan $char %c]
	set res 1
	for {set i 1} {$i <= $d} {incr i} {
		set res [expr "($res * $asc) % $n"]
	}
	set newchar [format "%c" $res]
	puts -nonewline $fileid2 $newchar
}
close $fileid2
puts "DECRYPTION COMPLETE ......"
}




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
    exec xgraph energy.xg  -t "Energy consumption" -x "time(sec)" -y "energy consumed" -bg white  &    
    exec xgraph pdr.xg  -t "PDR" -x "time" -y "PDR" -bg white  & 
    exec xgraph throughput.xg  -t "Throughput" -x "time" -y "no.of packets transmitted" -bg white  & 
    exec xgraph broadcast.xg  -t "delay" -x "time" -y "delay(sec)" -bg white  &
    
    exit 0
}
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "\$n$i reset"
}
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run
