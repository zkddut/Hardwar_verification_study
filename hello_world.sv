
// vcs -sverilog tb_top.sv
//vcs -sverilog +vpi +acc /xxx/xxx.cpp \
//-P /xxx/xxx.tab \
//-cpp g++ -ld g++ -CFLAGS -std=c99 -error=DCTTSW,REO,ENUMASSIGN,MATN,MIBMD,DPIMI,IRIMW,IPDASP,WAFFTA,IPDW,OBSLFLGS,NARW,AOUP,FLVU,INAV,VCM-INSOPTMIS,IPC,ISALS,CWUC,SV-ANDNMD,ECS,UNIQUE,PRIORITY \
//-CFLAGS -DVCS -xlrm uniq_prior_final -unit_timescale=1ps/1ps /import/vcs-release/vcsK-2015.09-SP2-7-mx/etc/uvm-1.2/uvm_pkg.sv \
//-assert novpi -ntb_define SVTB -error=DCTTSW,REO,SV-ANDNMD,ENUMASSIGN,MATN,MIBMD,DPIMI,IRIMW,SIOB,TMR,PCWM-W,PCWM-L,TMBIN,IPDASP,WAFFTA,IPDW,IWNF,IPC,TFIPC,OBSLFLGS,NARW,AOUP,FLVU,INAV,VCM-INSOPTMIS,TEIF \
//+systemverilogext+.sva+.sv+.inc+.svh+.def +notimingcheck +nospecify +delay_mode_path \
//+rad +nocelldefinepli+1 +vpi+1 -CFLAGS -DVCS -cm_name test +vcsd -P /import/cadist/pkgs/debussy/novas,vK-2015.09-SP2-7_Verdi3/5.x/share/PLI/VCS/LINUX/novas.tab \
///import/cadist/pkgs/debussy/novas,vK-2015.09-SP2-7_Verdi3/5.x/share/PLI/VCS/LINUX/pli.a \
//-l compile.log -file flist

//simv

program tb_top;

  class pkt;
    rand bit[3:0] data;

    constraint data_const { 
      data > 2;
    }
  endclass

  initial begin
    pkt a = new();
    repeat(5) begin
      a.randomize();
      $display("a.data:%0h",a.data);
    end
  end

endprogram

