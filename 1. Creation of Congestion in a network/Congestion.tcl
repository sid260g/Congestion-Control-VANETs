
# Create a simulator object 
set ns [new Simulator] 
  
# Define different colors  
# for data flows (for NAM) 
$ns color 1 Blue 
$ns color 2 Red 
$ns color 3 Green
  
# Open the NAM trace file 
set nf [open out1.nam w] 
$ns namtrace-all $nf 

#tracefile
set tracefile [open a1.tr w]
$ns trace-all $tracefile
  
# Define a 'finish' procedure 
proc finish {} { 
    global ns nf 
    $ns flush-trace 
      
    # Close the NAM trace file 
    close $nf 
      
    # Execute NAM on the trace file 
    exec nam out1.nam & 
    exit 0
} 
  
# Create five nodes 
set n0 [$ns node] 
set n1 [$ns node] 
set n2 [$ns node] 
set n3 [$ns node] 
set n4 [$ns node]
  
# Create links between the nodes 
$ns duplex-link $n0 $n2 3Mb 10ms DropTail 
$ns duplex-link $n1 $n2 3Mb 10ms DropTail 
$ns duplex-link $n4 $n2 3Mb 10ms DropTail
$ns duplex-link $n2 $n3 1Mb 20ms DropTail 
  
# Set Queue Size of link (n2-n3) to 10 
$ns queue-limit $n2 $n3 1000
  
# Give node position (for NAM) 
$ns duplex-link-op $n0 $n2 orient right-down 
$ns duplex-link-op $n1 $n2 orient right-up 
$ns duplex-link-op $n4 $n2 orient right
$ns duplex-link-op $n2 $n3 orient right 
  
# Monitor the queue for link (n2-n3). (for NAM) 
$ns duplex-link-op $n2 $n3 queuePos 0.5  
  
# Setup a UDP connection 
set udp [new Agent/UDP] 
$ns attach-agent $n1 $udp 
set null [new Agent/Null] 
  
$ns attach-agent $n3 $null 
$ns connect $udp $null 
$udp set fid_ 2

set udp1 [new Agent/UDP] 
$ns attach-agent $n0 $udp1
$ns connect $udp1 $null 
$udp1 set fid_ 1

set udp2 [new Agent/UDP] 
$ns attach-agent $n4 $udp2
$ns connect $udp2 $null 
$udp1 set fid_ 3
  
# Setup a CBR over UDP connection 
set cbr [new Application/Traffic/CBR] 
set cbr1 [new Application/Traffic/CBR] 
set cbr2 [new Application/Traffic/CBR] 
$cbr attach-agent $udp
$cbr1 attach-agent $udp1
$cbr2 attach-agent $udp2 
$cbr set type_ CBR 
$cbr set packet_size_ 5000
$cbr set rate_ 5mb
$cbr set random_ false 
  
$cbr1 set type_ CBR 
$cbr1 set packet_size_ 5000
$cbr1 set rate_ 5mb
$cbr1 set random_ false 

$cbr2 set type_ CBR 
$cbr2 set packet_size_ 5000
$cbr2 set rate_ 5mb
$cbr2 set random_ false 
  
# Schedule events for the CBR and FTP agents 
$ns at 0.1 "$cbr start"
$ns at 0.1 "$cbr1 start"
$ns at 0.1 "$cbr2 start"
$ns at 10.0 "$cbr stop"
$ns at 10.0 "$cbr1 stop"
$ns at 10.0 "$cbr2 stop"
  
# Call the finish procedure after 
# 5 seconds of simulation time 
$ns at 15.0 "finish"
  
# Print CBR packet size and interval 
puts "CBR packet size = [$cbr set packet_size_]"
puts "CBR interval = [$cbr set interval_]"
puts "CBR packet size = [$cbr1 set packet_size_]"
puts "CBR interval = [$cbr1 set interval_]"
puts "CBR packet size = [$cbr2 set packet_size_]"
puts "CBR interval = [$cbr2 set interval_]"
  
# Run the simulation 
$ns run 

