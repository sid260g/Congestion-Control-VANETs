ns aodv18.tcl
awk -f genthroughput.awk testAODV.tr
awk -f nrl_ot.awk testAODV.tr
awk -f pdr.awk testAODV.tr
nam testAODV.nam

