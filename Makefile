all                :


install            : HFIX.awk HTAG.awk
	echo     installing in b_nvdo
	_inst --bin HTAG
	_inst --bin HFIX
	_inst --bin HCSC

clean              :


remove             :

