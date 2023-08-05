all                :


install            : HFIX.awk HTAG.awk
	_inst --bin HTAG
	_inst --bin HTAG_call
	_inst --bin HTAG_gyges
	_inst --bin HFIX
	_inst --bin HFIX_recon
	_inst --bin HCSC
	_inst --bin HCOM

clean              :


remove             :


vi_edit            :
	vi -c "call HBUF_on()" -c "call HTAG_on()" HALL.vim HBUF.vim HFIX.vim HFIX_recon.awk HCSC.vim HTAG.vim HTAG_call.awk HCOM.vim

