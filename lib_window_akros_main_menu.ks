@lazyglobal off.

run lib_window.
run lib_window_menu.

function open_window_akros_main_menu{
	parameter os_data.

	local process is list(
		list(false,get_window_list(os_data),"update_window_akros_main_menu",true,0),
		"title_screen",ag1,"child_proc_place","reserved","reserved",
		"selected_program",os_data
	).
	return process.
}

function draw_window_akros_main_menu{
	parameter process.
	
	if not is_process_gui(process){
		return.
	}

	local window is get_process_window(process).

	print "aaa  k       OOOO SSSS" at(window[0]+2,window[1]+2).
	print "  a  k       O  O S   " at(window[0]+2,window[1]+3).
	print "aaa  k k rrr O  O SSSS" at(window[0]+2,window[1]+4).
	print "a a  kk  r   O  O    S" at(window[0]+2,window[1]+5).
	print "aaaa k k r   OOOO SSSS" at(window[0]+2,window[1]+6).

	print "Press 1 to start." at(window[0]+2,window[1]+8).

	print "v0.0, by akrasuski1" at(window[0]+window[2]-20,
									window[1]+window[3]-1).
	
	validate_process_window(process).
}

function update_window_akros_main_menu{
	parameter process.

	local run_mode is process[1].
	local wnd is get_process_window(process).
	local last_ag1 is process[2].
	set process[2] to ag1.
	local current_ag1 is process[2].
	local os_data is process[7].
	
	if run_mode="title_screen"{
		if process_needs_redraw(process){
			draw_window_akros_main_menu(process).
		}

		local wnd is get_process_window(process).

		if current_ag1<>last_ag1{
			draw_outline(wnd).
			set process[1] to "program_selection".
			local options is get_program_list().
			options:add("Back").
			options:add("Quit akrOS").
			local child_process is open_window_menu(
				get_window_list(os_data),
				0,
				"Select program:",
				options
			).
			set process[3] to child_process.
		}
	}
	else if run_mode="program_selection"{
		local child_process is process[3].
		if process_needs_redraw(process){ // pass redraw event to child
			invalidate_process_window(child_process).
			validate_process_window(process).
		}
		local selection is update_process(child_process).
		if process_finished(child_process){
			draw_outline(wnd).
			if selection="Quit akrOS"{
				local all_proc is get_process_list(os_data).
				local i is 0.
				until i=all_proc:length{
					end_process(all_proc[i]).
					set i to i+1.
				}
				return 0.
			}
			else if selection="Back"{
				set process[1] to "title_screen".
				invalidate_process_window(process).
			}
			else{
				local len is get_window_list(os_data):length.
				local lw is list().
				local i is 0.
				until i=len{
					lw:add(i).
					set i to i+1.
				}
				set child_process to open_window_menu(
					get_window_list(os_data),0,"Select window",lw
				).
				set process[1] to "window_selection".
				set process[3] to child_process.
				set process[6] to selection.
			}
		}
	}
	else if run_mode="window_selection"{
		local child_process is process[3].
		if process_needs_redraw(process){ // pass redraw event to child
			invalidate_process_window(child_process).
			validate_process_window(process).
		}
		local selection is update_process(child_process).
		if process_finished(child_process){
			draw_outline(wnd).
			
			local other_process is get_process_from_name(
				os_data,process[6],selection
			).

			if selection<>0{ // menu is still there
				local all_proc is get_process_list(os_data).
				all_proc:add(other_process).
				invalidate_process_window(process).
				set process[1] to "title_screen".
			}
			else{ // menu must disappear to show program
				set process[3] to other_process.
				set process[1] to "waiting_for_foreground".
			}
		}
	}
	else if run_mode="waiting_for_foreground"{
		local child_process is process[3].
		if process_needs_redraw(process){ // pass redraw event to child
			invalidate_process_window(child_process).
			validate_process_window(process).
		}
		update_process(child_process).
		if process_finished(child_process){
			draw_outline(wnd).
			invalidate_process_window(process).
			set process[1] to "title_screen".
		}
		else if current_ag1<>last_ag1{
			//this is fail-safe check to enable menu even if
			//user turns on non-interactive process on window 0.
			//On ag1, it is immediately killed.
			set process[1] to "title_screen".
			draw_outline(wnd).
			invalidate_process_window(process).
		}
	}
}
