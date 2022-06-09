# makefile to run analysis of cdom underway data for amt26

################################################################
.PHONY : help
help:
	@echo " "
	@echo "---------------- HOW TO RUN -------------------------------"
	@echo " "
	@echo "make all                  : run entire analysis "
	@echo "make cmp_ay               : (proc_cdom_amt_simple.m) extract ay and cy for each discrete MilliQ station"
	@echo "make cmp_ay_transect      : (cmp_ay_transect_simple.m) interpolate MQ along transect and extract ay values from each hourly 0.2um filtered datapoint of the transect"
	@echo "make figs                 : (prep_figs.m) prepare figures for paper"
	
	
	
	# @echo "make val                  : (cdom_validation.m) validate ACs estimates using LCWG"
	# @echo "make paper                : compile latex file"



#################################################################
###### compile paper
# DIN_ay = ~/Dropbox/Papers/ay/Express-LaTeX
#
# IN_ay = $(DIN_ay)/Submitted/ay_revised.tex \
# 	output/figs/cdom_validation.eps \
# 	output/figs/acy_spectra.eps
#
# M_ay = ./output/Output_files/cdom.oct \
#        prep_figs.m \
#        mq_sens.m \
#        cdom_validation.m
#
# OUT_ay = $(DIN_ay)/Submitted/ay_revised.pdf
#
# .PHONY : paper
# paper : $(OUT_ay)
#
# $(OUT_ay) : $(IN_ay) $(M_ay)
# # 	cd $(DIN_ay) && rm ay.aux ay.bbl ay.blg ay.log ay.pdf
# 	cd $(DIN_ay) && pdflatex $(IN_ay)  # see http://stackoverflow.com/questions/1789594/how-do-i-write-the-cd-command-in-a-makefile
# 	cd $(DIN_ay) && bibtex ay.aux
# 	cd $(DIN_ay) && pdflatex $(IN_ay)
# 	cd $(DIN_ay) && pdflatex $(IN_ay)
	



#################################################################
###### prepare all results
.PHONY : all
all : cmp_ay cmp_ay_transect figs #val 





################################################################
DOUT = /Users/gdal/Cruises/AMT29/Processed/Underway/cdom/


#################################################################
## 3) compute cdom for each MilliQ station

OUT_cmp_ay = $(DOUT)/acy_simple_wap.oct

IN_cmp_ay = ./input/ay_times.dat \
			./input/bad_MQs.dat
            
M_cmp_ay =  proc_cdom_amt_simple_WAP.m \
            common_processing_parameters.m          

.PHONY : cmp_ay
cmp_ay : $(OUT_cmp_ay)

$(OUT_cmp_ay) :  $(IN_cmp_ay) $(M_cmp_ay)
	octave -q  ./proc_cdom_amt_simple_WAP.m












#################################################################
## 4) analyse data for the entire cruise

OUT_cmp_ay_transect = $(DOUT)/cdom.oct

IN_cmp_ay_transect = $(DOUT)/acy_simple_wap.oct

M_cmp_ay_transect =  cmp_ay_transect_simple.m \
                     cmp_ay_transect_print_figures.m \
                     fit_ay_raw.m \
                     common_processing_parameters.m          

.PHONY : cmp_ay_transect
cmp_ay_transect : $(OUT_cmp_ay_transect)


$(OUT_cmp_ay_transect) :  $(IN_cmp_ay_transect) $(M_cmp_ay_transect) 
	octave -q  ./cmp_ay_transect_simple.m




#################################################################
## 5) prepare figures for paper
DFIGS = "/Users/gdal/Cruises/AMT29/Figures/cdom/"

OUT_figs = $(DFIGS)/acy440_vs_Sy_with_SST.png \
           $(DFIGS)/acy_spectra.png


IN_figs = $(DOUT)/cdom.oct \
          $(DOUT)/amt_chl_vs_ayp440.oct

M_figs = prep_figs.m \
         plot_diffs.m \
         mq_sens.m

.PHONY : figs 
figs : $(OUT_figs)

$(OUT_figs) : $(IN_figs) $(M_figs)
	octave -q  ./prep_figs.m




#
# #################################################################
# ## 6) run validation
#
#
# OUT_val = output/figs/cdom_validation.eps
#
# IN_val = $(DOUT)/cdom.oct \
#          input/ctd_und_stations.txt
#
# M_val = cdom_validation.m \
#         rd_lcwg_fn.m
#
# .PHONY : val
# val : $(OUT_val)
#
# $(OUT_val) : $(IN_val) $(M_val)
# 	octave -q  ./cdom_validation.m





























