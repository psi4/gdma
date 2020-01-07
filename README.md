## GDMA 2.3: Distributed Multipole Analysis for Gaussian wavefunctions

The GDMA program carries out Distributed Multipole Analysis of
wavefunctions calculated by the Gaussian system of programs or the
Psi4 package, using the
formatted checkpoint files that they can produce. The result is a set of
multipole moments at sites defined by the user (usually at the
positions of the atomic nuclei) which, given an accurate wavefunction,
provide an accurate description of the electrostatic field of the
molecule.

Version 2 handles diffuse functions more satisfactorily
than version 1, giving results which converge rapidly to steady values
as the basis set is improved. It is not as fast, typically requiring
minutes of cpu time, or even an hour or two for large molecules,
rather than a few seconds, but it is still
fast compared with the wavefunction calculation. The original algorithm,
as used in version 1, is still available in version 2, and is still the
best choice for accurate electrostatic potentials as well as being much
faster, but the multipole moments may not correspond to chemical intuition
and will change as the basis set is improved.

More details are in
A. J. Stone, J. Chem Theory Comp. (2005) 1, 1128-1132. Please cite
this reference in published work that uses GDMA. 

The program is available from this repository for general use, subject
to the licence in the file LICENCE included with the package. 
Recommended procedure is to use the command
```
git clone https://gitlab.com/anthonyjs/gdma.git
```
which will clone the code into a new directory `gdma`.

Installation instructions are in the file INSTALL included with the
package and full documentation is in the program manual at doc/manual.pdf
