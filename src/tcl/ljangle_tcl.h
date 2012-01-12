/*
  Copyright (C) 2010 The ESPResSo project
  Copyright (C) 2002,2003,2004,2005,2006,2007,2008,2009,2010 
    Max-Planck-Institute for Polymer Research, Theory Group
  
  This file is part of ESPResSo.
  
  ESPResSo is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.
  
  ESPResSo is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
  
  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>. 
*/
#ifndef _LJANGLE_TCL_H
#define _LJANGLE_TCL_H

/** \file ljangle.h
 *  Routines to calculate the lennard-jones 12-10 with angular dependance.
 *  The potential is a product of a 12-10 LJ potential with two cos^2.
 *  The potential actually relies on 6 particles: the 2 primary beads
 *  and each bead needs two other particles to define an orientation.
 *  We calculate the interaction explicitly *without* the use of the ROTATION feature.
 *
 *  Optional: simulate two different environments in which the interaction
 *  strengths differ. For example: simulate hydrogen-bonds both in water and
 *  inside a bilayer. The two environments are distinguished by their
 *  z-position. Input: the midplane of the 2nd environment, its total
 *  thickness, the thickness of the interface, and the value of the
 *  interaction strength in this medium. The interaction strengh of the second
 *  environment must be *stronger* than of the first one.
 *
 *  \ref forces.c
 */

#ifdef LJ_ANGLE
#include <math.h>

/* These headers are needed to define types used in this header, hence
 * they are included here.  */
#include "particle_data.h"
#include "interaction_data.h"

int tclprint_to_result_ljangleIA(Tcl_Interp *interp, int i, int j);

/** set the force cap for the directional LJ interaction.
    @param ljangleforcecap the maximal force, 0 to disable, -1 for individual cutoff
    for each of the interactions.
*/

/// parser for the forcecap
int tclcommand_inter_parse_ljangleforcecap(Tcl_Interp * interp, int argc, char ** argv);


int tclcommand_inter_parse_ljangle(Tcl_Interp * interp,
			    int part_type_a, int part_type_b,
			    int argc, char ** argv);



#endif /* ifdef LJ_ANGLE */
/* LJANGLE_H */
#endif 

