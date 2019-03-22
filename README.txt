                   GDMA version 2.3

The GDMA program carries out distributed multipole analysis of
wavefunctions calculated by the Gaussian system of programs, using the
formatted checkpoint files that they produce. The result is a set of
multipole moments at sites defined by the user (usually at the
positions of the atomic nuclei) which, given an accurate wavefunction,
provide an accurate description of the electrostatic field of the
molecule. Version 2 handles diffuse functions more satisfactorily than
version 1, giving results which converge rapidly to steady values as
the basis set is improved. It is not as fast, typically requiring
minutes of cpu time, or even an hour or two for large molecules,
rather than a few seconds, but it is still fast compared with the
wavefunction calculation. The original algorithm, as used in version
1, is still available in version 2, and is very much faster than
the new version, but it is not recommended for use with large basis
sets containing very diffuse functions. More details are in A. J.
Stone, J. Chem Theory Comp. (2005) 1, 1128-1132.

Obtaining the program
---------------------

In a suitable directory, run the command
  git clone https://git.uis.cam.ac.uk/x/ch-stone/u/ajs1/gdma.git
This will construct a clone of the program files in the subdirectory
gdma.

Documentation
-------------

Full documentation is in gdma/doc/manual.pdf.

