namespace eval ::ia840f_emif_plan01 {
    variable armed 0
    variable callback_count 0
}
proc ::ia840f_emif_plan01::before_delete {} {
    variable armed
    variable callback_count
    set armed 0
    incr callback_count
    post_message -type info [list EMIF_PLAN_CALLBACK_ENTER $callback_count app $::TimeQuestInfo(nameofexecutable)]
    if {$callback_count > 8} {
        post_message -type info [list EMIF_PLAN_CALLBACK_CAP $callback_count]
        return
    }
    set __ep_report [format {/home/uwb_student00/ahls/new_BSP/qualification/emif-hold-objective-01/plan-diagnostic01/reports/predelete-%02d-sdc.rpt} $callback_count]
    set __ep_rc [catch {report_sdc -ignored -file $__ep_report} __ep_msg]
    post_message -type info [list EMIF_PLAN_CALLBACK_RESULT $callback_count rc $__ep_rc message $__ep_msg file $__ep_report]
}
proc ::ia840f_emif_plan01::arm {} {
    variable armed
    if {!$armed} {
        set __ep_rc [catch {register_delete_timing_netlist_callback ::ia840f_emif_plan01::before_delete} __ep_msg]
        post_message -type info [list EMIF_PLAN_CALLBACK_REGISTER rc $__ep_rc message $__ep_msg]
        if {$__ep_rc == 0} {set armed 1}
    }
}
