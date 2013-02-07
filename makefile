DATE  = `date +%Y%m%d-%H%M`
FLAGS =-Wall -m64 -Os # -wd981 -g -Werror -wd593 -Wwrite-strings -Wmissing-declarations -Wuninitialized -Wstrict-prototypes -Wmissing-prototypes -std=c99 -Wshadow
CFLAGS = $(FLAGS)

FOLDER = $(CURDIR)
NAME = $(notdir $(CURDIR))
MYDIR=/nv/hp5/jriousset6/data/${NAME}
NODES=1
PPN=64
PROCS= $(shell echo ${NODES}*${PPN} | bc)

include ${PETSC_DIR}/conf/variables
include ${PETSC_DIR}/conf/rules

#SOURCES = $(wildcard *.c)

SOURCES = MyProfiles.c MyCtx.c MyMonitor.c MyPDEs.c

OBJECTS = $(SOURCES:.c=.o)

all: $(OBJECTS) main_exe conv_exe

main_exe: main.o chkopts ${OBJECTS}
	${CLINKER} -o main main.o ${OBJECTS} ${PETSC_LIB}
	
conv_exe: convert.o chkopts ${OBJECTS}
	${CLINKER} -o convert convert.o ${OBJECTS} ${PETSC_LIB}

run:
	#rm -rfv ~/${NAME}.sh ~/log${NAME}.o* #output/* viz_dir/log.out
	#export PETSC_DIR=/usr/local/packages/petsc-3.2-p6/
	#export PETSC_ARCH=arch-linux2-c-debug
	#cp ~/M4_RK.5 ~/${NAME}.sh
	cp ~/M4_RK.6 ~/${NAME}.sh
	qsub -N log${NAME} -l nodes=${NODES}:ppn=${PPN} -l walltime=100:00:00 -l pmem=3gb -v MYDIR=${MYDIR},MYPROCS=${PROCS} -z ~/${NAME}.sh 
	#mpirun -n 8 ./main -options_file input/main.in # > viz_dir/log.out
	
conv:
	#${RUN} -n 8 ./convert -options_file input/main.in > out.dat
	#rm -rfv viz_dir/*.dat viz_dir/*.general viz_dir/*.*if* viz_dir/*.png
	./convert -options_file input/main.in
	
run_help:	
	reset
	./main -options_file input/main.in -help

clr_dat:
	rm -rfv .nfs* .*.swp input/.*.swp viz_dir/*.dat viz_dir/*.general viz_dir/*.*if* viz_dir/*.png viz_dir/*.pdf viz_dir/*.eps viz_dir/*.ps 
clr_img:
	rm -rfv .nfs* .*.swp input/.*.swp viz_dir/*.*if* viz_dir/*.png viz_dir/*.pdf viz_dir/*.eps viz_dir/*.ps 
clear:
	rm -rfv *.o .nfs* .*.swp main convert input/.*.swp output/* viz_dir/*.dat viz_dir/*.general viz_dir/*.*if* viz_dir/*.png viz_dir/log.out ~/${NAME}.sh ~/log${NAME}.*
