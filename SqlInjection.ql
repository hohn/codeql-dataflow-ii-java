/**
 * @name SQLI Vulnerability
 * @description Using untrusted strings in a sql query allows sql injection attacks.
 * @kind path-problem
 * @id dataflow-ii/SQLIVulnerable
 * @problem.severity warning
 */

import java
import semmle.code.java.dataflow.TaintTracking
import DataFlow::PathGraph

class SqliFlowConfig extends TaintTracking::Configuration {
  SqliFlowConfig() { this = "SqliFlow" }

  override predicate isSource(DataFlow::Node source) {
    // System.console().readLine();
    exists(Call read |
      read.getCallee().getName() = "readLine" and
      read = source.asExpr()
    )
  }

  override predicate isSanitizer(DataFlow::Node sanitizer) {
    // 
    // no_semi1(get_user_info());
    // exists(Call nosemi |
    //   nosemi.getCallee().getName().matches("no_sem%")
    //   and (
    //     sanitizer.asExpr() = nosemi  // no no_semi
    //   )
    // ) or
    //
    // no_semi(info);
    //
    exists(Call nosemi, Variable info, VarAccess useinfo |
      nosemi.getCallee().getName().matches("no_semi") and
      nosemi.getAnArgument() = info.getAnAccess() and
      useinfo.getVariable() = info and
      nosemi.getEnclosingStmt().getControlFlowNode().getASuccessor+() = useinfo and
      sanitizer.asExpr() = useinfo
    )
    //
    // exists(Call noSemi |
    //   noSemi.getCallee().getName() = "no_semi1"
    //   and sanitizer.asExpr() = noSemi // try this alone, notice missing no_semi
    //   )
    // none()
  }

  override predicate isAdditionalTaintStep(DataFlow::Node into, DataFlow::Node out) {
    // Extra taint step; have to get past
    // String query = Utils.concat(insertPart, values);
    exists(MethodAccess ma |
      ma.getMethod().getName().matches("concat") and
      into.asExpr() = ma.getAnArgument() and
      out.asExpr() = ma
    )
    // exists(MethodAccess ma | ma.getMethod().hasName("concat") |
    //   ma.getAnArgument() = into.asExpr() and
    //   ma = out.asExpr()
    // )
    //  none()
  }

  override predicate isSink(DataFlow::Node sink) {
    // conn.createStatement().executeUpdate(query);
    // any()
    exists(Call exec |
      exec.getCallee().getName() = "executeUpdate" and
      exec.getArgument(0) = sink.asExpr()
    )
  }
}

// from SqliFlowConfig conf, DataFlow::PathNode source, DataFlow::PathNode sink
// where conf.hasFlowPath(source, sink)
// select sink, source, sink, "Possible SQL injection"
from SqliFlowConfig conf, DataFlow::PathNode source, DataFlow::PathNode sink
where conf.hasFlowPath(source, sink)
select sink, source, sink, "Possible SQL injection"
