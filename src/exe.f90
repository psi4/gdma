program gdma

USE input
USE version
USE dma
USE atom_grids, ONLY: debug_grid => debug
USE timing, ONLY: start_timer, timer, time_and_date
use libgdma
!IMPLICIT NONE
!
!INTEGER, PARAMETER :: dp=kind(1d0)
!
!CHARACTER(LEN=100) :: file
!CHARACTER(LEN=80) :: buffer
!CHARACTER(LEN=20) :: key
!CHARACTER(LEN=8) :: whichd="SCF"
!CHARACTER(LEN=24) :: datestring
!
!!  Maximum number of sites is number of atoms + nextra
!INTEGER :: nextra=16
!INTEGER :: ncoorb, maxl, cmax, nprim, nx, num, ich, mul
!INTEGER, ALLOCATABLE :: shell_type(:)
!INTEGER :: i, j, k, kp=0
!LOGICAL :: eof, fchk, first, ok=.false.
!
!REAL(dp), ALLOCATABLE :: densty(:,:), dtri(:)
!INTEGER :: ir=5 ! Input stream
!
!LOGICAL :: verbose=.false., debug(0:2)=.false.


print "(15x,a/15x,a//15x,a//15x,5a/14x,4a)",                           &
    "                      G D M A",                                   &
    "                  by Anthony Stone",                              &
    "Distributed Multipoles from Gaussian wavefunctions",              &
    "              version ", gdma_version, " (", commit, ")",         &
    "Compiled with ", compiler, " on ", compiled
call time_and_date(datestring)
print "(/2A)", "Starting at ", datestring

call start_timer

punchfile="dma.punch"
nat=0
fchk=.false.
first=.true.
do
  call read_line(eof)
  if (eof) exit
  call readu(key)
  select case(key)
  case("","NOTE","!")
    cycle
  case("VERBOSE")
    verbose=.true.
  case("QUIET")
    debug=.false.
    verbose=.false.
  case("DEBUG")
    debug(0)=.true.
    do while (item<nitems)
      call readi(k)
      if (k>0) then
        debug(k)=.true.
      else
        debug(-k)=.false.
      end if
    end do
    debug_grid=.true.
    verbose=.true.
  case("ANGSTROM")
    rfact=bohr
  case("BOHR")
    rfact=1d0
  case("SI")
    Qfactor(0)=echarge
    do k=1,20
      Qfactor(k)=Qfactor(k-1)*bohr
    end do
  case("AU")
    Qfactor=1d0
  case("COMMENT","TITLE")
    call reada(buffer)
    print "(/a/)", trim(buffer)
  case("DENSITY")
    if (fchk) call die                                         &
        ("Specify density to use before reading data file",.true.)
    call readu(whichd)
  case("FILE","READ")
    nat=0
    fchk=.false.
    ok=.false.
    first=.true.
    if (allocated(dtri)) deallocate(dtri)
    do while (item<nitems)
      call readu(key)
      select case(key)
      case("DENSITY")
        call readu(whichd)
      case default
        call reread(-1)
        call reada(file)
        open(unit=9,file=file,status="old",iostat=k)
        if (k .ne. 0) then
          call die("Can't open file "//file,.true.)
        endif
      end select
    end do
    ir=9
    call get_data(whichd,ok,5)
    close(9)
    ir=5
    fchk=.true.
  case ("HERE")
    call get_data(whichd,ok,5)
    fchk=.true.
  case("NAMES")
    if (.not. fchk) call die                                   &
        ("Read data file before specifying atom names",.false.)
    call read_line(eof)
    do i=1,nat
      call geta(name(i))
    end do
  case("GO","START","MULTIPOLES")
    if (.not. ok) then
      call die (trim(whichd)//" density not found",.false.)
    endif
    if (first) then
      ! convert density matrix to triangular form
      allocate(dtri(nx))
      k=0
      do i=1,num
        do j=1,i
          k=k+1
          dtri(k)=densty(i,j)
        end do
      end do
      deallocate(densty)
      first=.false.
    endif
    print "(//2A/)", "Using "//trim(whichd)//" density matrix",  &
        " from file "//trim(file)
    call dma_main(dtri,kp,5,6)
    call timer
  case("RESET")
    nat=0
    fchk=.false.
    ok=.false.
    first=.true.
    deallocate(dtri)
    whichd="SCF"
  case("FINISH")
    exit
  case default
    call die("Keyword "//trim(key)//" not recognized",.true.)
  end select
end do

call time_and_date(datestring)
print "(/2A)", "Finished at ", datestring

END program gdma

