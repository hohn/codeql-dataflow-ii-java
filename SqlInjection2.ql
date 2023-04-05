/**
 * @name SQLI Vulnerability
 * @description Using untrusted strings in a sql query allows sql injection attacks.
 * @ kind path-problem
 * @id dataflow-ii/SQLIVulnerable
 * @problem.severity warning
 */

import java
import semmle.code.java.dataflow.TaintTracking
import DataFlow::PathGraph
import semmle.code.java.dataflow.DataFlow

class SqlSanitizer extends DataFlow::BarrierGuard {
  override predicate checks(Expr e, boolean branch) {
    exists(IfStmt ifs |
      ifs.getEnclosingCallable().getName() = "no_semi" and
      // ifs.getCondition().getType().toString().matches("%")
      branch = true and
      ifs.getCondition() = e
    )
  }
}

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
    exists(Call noSemi |
      noSemi.getCallee().getName() = "no_semi1" 
      and sanitizer.asExpr() = noSemi // try this alone, notice missing no_semi
      )
  }

  override predicate isAdditionalTaintStep(DataFlow::Node into, DataFlow::Node out) {
    none()
  }

  override predicate isSink(DataFlow::Node sink) {
    // check flow reach, manually.
    // exists(Call exec |
    //   exec.getCallee().getName() = "executeUpdate" and
    //   exec.getArgument(0) = sink.asExpr()
    // )
    any()
  }
}

/* from SqliFlowConfig conf, DataFlow::PathNode source, DataFlow::PathNode sink
where conf.hasFlowPath(source, sink)
select sink, source, sink, "Possible SQL injection"
 */

// check flow reach, manually.
from SqliFlowConfig conf, DataFlow::Node source, DataFlow::Node sink
where conf.hasFlow(source, sink)
select source, sink
 