initial $display("\033[7;38m################ TEST STARTED ################\033[0m");

longint passed_cases;
longint failed_cases;

string top_name;
string test_name;
int test_count;
int vcd;
int debug;

function automatic void note_case(bit pass);
  if (pass) passed_cases++;
  else failed_cases++;
endfunction

initial begin

  top_name = $sformatf("%m");

  if (!$value$plusargs("TN=%s", test_name)) begin
    test_name = "default";
  end

  if (!$value$plusargs("TC=%d", test_count)) begin
    test_count = 1;
  end

  if (!$value$plusargs("VCD=%d", vcd)) begin
    vcd = 0;
  end

  if (vcd) begin
    $dumpfile($sformatf("%s.vcd", top_name));
    $dumpvars(0);
  end

  if (!$value$plusargs("DEBUG=%d", debug)) begin
    debug = 0;
  end

  $display("SIMULATING TOP: %s, TEST: %s, COUNT: %0d, VCD: %0d, DEBUG: %0d", top_name, test_name,
           test_count, vcd, debug);

end

final begin
  $display("\033[7;38m################# TEST ENDED #################\033[0m");
  $display("PASSED CASES: %0d, FAILED CASES: %0d", passed_cases, failed_cases);
  if (failed_cases == 0 && passed_cases != 0) begin
    $display("\033[1;32mTEST PASSED\033[0m");
  end else begin
    $display("\033[1;31mTEST FAILED\033[0m");
  end
end
