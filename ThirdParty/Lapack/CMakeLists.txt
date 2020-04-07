cmake_minimum_required (VERSION 2.6)
project (LAPACK)
enable_language (Fortran)

# Get the install directory
if(CMAKE_INSTALL_DIR)
    set(LAPACK_INSTALL_DIR ${CMAKE_INSTALL_DIR})
else()
    set(LAPACK_INSTALL_DIR ${CMAKE_BINARY_DIR}/../install)
    message(STATUS "Install dir not defined, using ${LAPACK_INSTALL_DIR}")
endif()
message(STATUS LAPACK_INSTALL_DIR=${LAPACK_INSTALL_DIR})

set (lapack_srcs
    dgecon.f  dgeqpf.f  dggev.f   dlabad.f  dlaev2.f    dlaneg.f  dlaqps.f  dlarra.f  dlasd2.f  dlasv2.f  dorghr.f  dormtr.f  dppequ.f  dsbgv.f   dstebz.f  dsygvx.f  dtgsyl.f  ilaver.f
    dgeequ.f  dgeqr2.f  dggevx.f  dlabrd.f  dlaexc.f    dlangb.f  dlaqr0.f  dlarrb.f  dlasd3.f  dlaswp.f  dorgl2.f  dpbcon.f  dpprfs.f  dsbgvd.f  dstedc.f  dsyrfs.f  dtpcon.f  iparmq.f
    dgees.f   dgeqrf.f  dggglm.f  dlacn2.f  dlag2.f     dlange.f  dlaqr1.f  dlarrc.f  dlasd4.f  dlasy2.f  dorglq.f  dpbequ.f  dppsv.f   dsbgvx.f  dstegr.f  dsysv.f   dtprfs.f  lsamen.f
    dgeesx.f  dgerfs.f  dgghrd.f  dlacon.f  dlag2s.f    dlangt.f  dlaqr2.f  dlarrd.f  dlasd5.f  dlasyf.f  dorgql.f  dpbrfs.f  dppsvx.f  dsbtrd.f  dstein.f  dsysvx.f  dtptri.f
    dbdsdc.f        dgeev.f   dgerq2.f  dgglse.f  dlacpy.f  dlags2.f    dlanhs.f  dlaqr3.f  dlarre.f  dlasd6.f  dlatbs.f  dorgqr.f  dpbstf.f  dpptrf.f  dsgesv.f  dstemr.f  dsytd2.f  dtptrs.f
    dbdsqr.f        dgeevx.f  dgerqf.f  dggqrf.f  dladiv.f  dlagtf.f    dlansb.f  dlaqr4.f  dlarrf.f  dlasd7.f  dlatdf.f  dorgr2.f  dpbsv.f   dpptri.f  dspcon.f  dsteqr.f  dsytf2.f  dtrcon.f
    ddisna.f        dgegs.f   dgesc2.f  dggrqf.f  dlae2.f   dlagtm.f    dlansp.f  dlaqr5.f  dlarrj.f  dlasd8.f  dlatps.f  dorgrq.f  dpbsvx.f  dpptrs.f  dspev.f   dsterf.f  dsytrd.f  dtrevc.f
    dgbbrd.f        dgegv.f   dgesdd.f  dggsvd.f  dlaebz.f  dlagts.f    dlanst.f  dlaqsb.f  dlarrk.f  dlasda.f  dlatrd.f  dorgtr.f  dpbtf2.f  dptcon.f  dspevd.f  dstev.f   dsytrf.f  dtrexc.f
    dgbcon.f        dgehd2.f  dgesv.f   dggsvp.f  dlaed0.f  dlagv2.f    dlansy.f  dlaqsp.f  dlarrr.f  dlasdq.f  dlatrs.f  dorm2l.f  dpbtrf.f  dpteqr.f  dspevx.f  dstevd.f  dsytri.f  dtrrfs.f
    dgbequ.f        dgehrd.f  dgesvd.f  dgtcon.f  dlaed1.f  dlahqr.f    dlantb.f  dlaqsy.f  dlarrv.f  dlasdt.f  dlatrz.f  dorm2r.f  dpbtrs.f  dptrfs.f  dspgst.f  dstevr.f  dsytrs.f  dtrsen.f
    dgbrfs.f        dgelq2.f  dgesvx.f  dgtrfs.f  dlaed2.f  dlahr2.f    dlantp.f  dlaqtr.f  dlartg.f  dlaset.f  dlatzm.f  dormbr.f  dpocon.f  dptsv.f   dspgv.f   dstevx.f  dtbcon.f  dtrsna.f
    dgbsv.f         dgelqf.f  dgetc2.f  dgtsv.f   dlaed3.f  dlahrd.f    dlantr.f  dlar1v.f  dlartv.f  dlasq1.f  dlauu2.f  dormhr.f  dpoequ.f  dptsvx.f  dspgvd.f  dsycon.f  dtbrfs.f  dtrsyl.f
    dgbsvx.f        dgels.f   dgetf2.f  dgtsvx.f  dlaed4.f  dlaic1.f    dlanv2.f  dlar2v.f  dlaruv.f  dlasq2.f  dlauum.f  dorml2.f  dporfs.f  dpttrf.f  dspgvx.f  dsyev.f   dtbtrs.f  dtrti2.f
    dgbtf2.f        dgelsd.f  dgetrf.f  dgttrf.f  dlaed5.f  dlaisnan.f  dlapll.f  dlarf.f   dlarz.f   dlasq3.f  dlazq3.f  dormlq.f  dposv.f   dpttrs.f  dsprfs.f  dsyevd.f  dtgevc.f  dtrtri.f
    dgbtrf.f        dgelss.f  dgetri.f  dgttrs.f  dlaed6.f  dlaln2.f    dlapmt.f  dlarfb.f  dlarzb.f  dlasq4.f  dlazq4.f  dormql.f  dposvx.f  dptts2.f  dspsv.f   dsyevr.f  dtgex2.f  dtrtrs.f
    dgbtrs.f        dgelsx.f  dgetrs.f  dgtts2.f  dlaed7.f  dlals0.f    dlapy2.f  dlarfg.f  dlarzt.f  dlasq5.f  dopgtr.f  dormqr.f  dpotf2.f  drscl.f   dspsvx.f  dsyevx.f  dtgexc.f  dtzrqf.f
    dgebak.f        dgelsy.f  dggbak.f  dhgeqz.f  dlaed8.f  dlalsa.f    dlapy3.f  dlarft.f  dlas2.f   dlasq6.f  dopmtr.f  dormr2.f  dpotrf.f  dsbev.f   dsptrd.f  dsygs2.f  dtgsen.f  dtzrzf.f
    dgebal.f        dgeql2.f  dggbal.f  dhsein.f  dlaed9.f  dlalsd.f    dlaqgb.f  dlarfx.f  dlascl.f  dlasr.f   dorg2l.f  dormr3.f  dpotri.f  dsbevd.f  dsptrf.f  dsygst.f  dtgsja.f  dzsum1.f
    dgebd2.f        dgeqlf.f  dgges.f   dhseqr.f  dlaeda.f  dlamch.f    dlaqge.f  dlargv.f  dlasd0.f  dlasrt.f  dorg2r.f  dormrq.f  dpotrs.f  dsbevx.f  dsptri.f  dsygv.f   dtgsna.f  ieeeck.f
    dgebrd.f        dgeqp3.f  dggesx.f  disnan.f  dlaein.f  dlamrg.f    dlaqp2.f  dlarnv.f  dlasd1.f  dlassq.f  dorgbr.f  dormrz.f  dppcon.f  dsbgst.f  dsptrs.f  dsygvd.f  dtgsy2.f  ilaenv.f
    )

add_library (lapack STATIC ${lapack_srcs})

install (TARGETS lapack 
   LIBRARY DESTINATION ${LAPACK_INSTALL_DIR} COMPONENT library
   ARCHIVE DESTINATION ${LAPACK_INSTALL_DIR} COMPONENT library
   RUNTIME DESTINATION ${LAPACK_INSTALL_DIR} COMPONENT library)
