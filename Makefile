all                :


install            : HFIX.awk HTAG.awk
	echo     installing in b_nvdo
	_inst --bin HTAG
	_inst --bin HTAG_call
	_inst --bin HTAG_gyges
	_inst --bin HFIX
	_inst --bin HCSC

clean              :


remove             :

