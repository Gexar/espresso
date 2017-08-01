#############################################################
#                                                           #
# shanchen.tcl                                              #
# ============                                              #
#                                                           #
# Script to setup droplets in bicomponent fluids            #
#                                                           #
#############################################################
# Copyright (C) 2010,2012,2013,2014 The ESPResSo project
# Copyright (C) 2002,2003,2004,2005,2006,2007,2008,2009,2010 
#   Max-Planck-Institute for Polymer Research, Theory Group
#  
# This file is part of ESPResSo.
#  
# ESPResSo is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#  
# ESPResSo is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#  
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>. 
#
proc droplet { args } { 
	require_feature "SHANCHEN"
	set USAGE  "Usage of \"droplet\":\ndroplet x y z Radius (sphere|cylinder|slab) \[ direction #integer\] \[min max #num_dens\] \[width\] \[overwriting #1||0\]"


	set dl [setmd box_l]
	set bx [ lindex $dl 0 ]
	set by [ lindex $dl 1 ]
	set bz [ lindex $dl 2 ]

	#default values
	set min 0.06
	set max 2.3
	set width 2 
	set params [lbfluid parameters]
	set agrid [lindex $params 0 1]
	set overwrite 1

	if { [llength $args ] < 5 } { 
		error $USAGE
	}
        set direction 0
	set cx [lindex $args 0]
	set cy [lindex $args 1]
	set cz [lindex $args 2]
	set center [list $cx $cy $cz]
	set R  [lindex $args 3]
	set type [lindex $args 4]
	if { $type != "sphere" } {
		set direction [lindex $args 5]
	} 
	if {[llength $args] > 6}  { 
	   if {[llength $args ]< 8}  { 
		error "you should provide two density values, min and max\n$USAGE"
	   }
	   set min [lindex $args 6]
	   set max [lindex $args 7]
	}
	if {[llength $args] > 8}  { 
	   set overwriting [lindex $args 8]
	}
	if {[llength $args] > 9}  { 
		error "too many args!\n$USAGE"
	}	
	for { set x  0 } { $x < $bx } { incr x } { 
    		for {set y 0} { $y < $by } { incr y } { 
        		for {set z 0} { $z < $bz } { incr z } { 
				set r [list  [expr $agrid*$x] [expr $agrid*$y] [expr $agrid* $z] ]
				set bufdens [lbnode $x $y $z print rho]
				set rhoa_node [lindex $bufdens 0] 
				set rhob_node [lindex $bufdens 1]
				switch  $type { 
            				"slab"  { 
						  set pos    [lindex $r $direction] 
						  set h1     [expr [lindex $center $direction] - 0.5*$R]
						  set h2     [expr [lindex $center $direction] + 0.5*$R]
						  if { $overwriting == 1 } {
							  set rho_a  [expr $max+(($min-$max)*0.25*((1.+tanh(($h2-$pos)/$width))*(1.+tanh(($pos-$h1)/$width)))) ] 
							  set rho_b  [expr $min+(($max-$min)*0.25*((1.+tanh(($h2-$pos)/$width))*(1.+tanh(($pos-$h1)/$width)))) ] 
						  } else {
							  if { $rhoa_node < $rho_a } {
								  set rho_a  [expr $max+(($min-$max)*0.25*((1.+tanh(($h2-$pos)/$width))*(1.+tanh(($pos-$h1)/$width)))) ] 
								  set rho_b  [expr $min+(($max-$min)*0.25*((1.+tanh(($h2-$pos)/$width))*(1.+tanh(($pos-$h1)/$width)))) ] 
							  } else {
								  set rho_a $rhoa_node 
								  set rho_b $rhob_node
							  }
						  }
					}
					"cylinder"  { 
						  set dist 0
						  for { set dir 0 } { $dir < 3} { incr dir} {
							if {$direction == $dir} { continue } 
						        set pos    [lindex $r $dir] 
						  	set c      [lindex $center $dir]
							set dist [expr $dist + ($pos-$c)*($pos - $c)]
						  }
						  set dist [expr sqrt($dist)]
            					  set rho_a  [expr $max+(($min-$max)*0.5*(1.+tanh(($dist-$R)/$width))) ] 
						  set rho_b  [expr $min+(($max-$min)*0.5*(1.+tanh(($dist-$R)/$width))) ] 
					}
					"sphere"  { 
						  set dist 0
						  for { set direction 0 } { $direction < 3} { incr direction } {
						        set pos    [lindex $r $direction] 
						  	set c      [lindex $center $direction ]
							set dist [expr $dist + ($pos-$c)*($pos - $c)]
						  }
						  set dist [expr sqrt($dist)]
            					  set rho_a  [expr $max+(($min-$max)*0.5*(1.+tanh(($dist-$R)/$width))) ] 
						  set rho_b  [expr $min+(($max-$min)*0.5*(1.+tanh(($dist-$R)/$width))) ] 
						  if { $overwriting == 1 } {
							  set rho_a  [expr $max+(($min-$max)*0.5*(1.+tanh(($dist-$R)/$width))) ] 
							  set rho_b  [expr $min+(($max-$min)*0.5*(1.+tanh(($dist-$R)/$width))) ] 
						  } else {
							  if { $rhoa_node < $rho_a } {
								  set rho_a  [expr $max+(($min-$max)*0.5*(1.+tanh(($dist-$R)/$width))) ] 
								  set rho_b  [expr $min+(($max-$min)*0.5*(1.+tanh(($dist-$R)/$width))) ] 
							  } else {
								  set rho_a $rhoa_node 
								  set rho_b $rhob_node
							  }
						  }
					}
				}
            			lbnode $x $y $z set rho  $rho_a $rho_b
        		}
    		}
	}
}
