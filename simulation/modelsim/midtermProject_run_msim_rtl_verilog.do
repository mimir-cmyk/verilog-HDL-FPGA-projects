transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/LABSTUFF/midterm {C:/intelFPGA_lite/LABSTUFF/midterm/baseline_c5gx.v}
vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/LABSTUFF/midterm {C:/intelFPGA_lite/LABSTUFF/midterm/rom_3x8.v}
vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/LABSTUFF/midterm {C:/intelFPGA_lite/LABSTUFF/midterm/counter.v}
vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/LABSTUFF/midterm {C:/intelFPGA_lite/LABSTUFF/midterm/reg8.v}
vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/LABSTUFF/midterm {C:/intelFPGA_lite/LABSTUFF/midterm/top_module.v}
vlog -vlog01compat -work work +incdir+C:/intelFPGA_lite/LABSTUFF/midterm {C:/intelFPGA_lite/LABSTUFF/midterm/clock_divider.v}

