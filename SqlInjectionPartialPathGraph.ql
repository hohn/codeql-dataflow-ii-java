/**
 * @name SQLI Vulnerability
 * @description Using untrusted strings in a sql query allows sql injection attacks.
 * @kind path-problem
 * @id dataflow-ii/SQLIVulnerable
 * @problem.severity warning
 */

import java
import semmle.code.java.dataflow.TaintTracking

module MyTaintConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    // System.console().readLine();
    exists(Call read |
      read.getCallee().getName() = "readLine" and
      read = source.asExpr()
    )
  }

  predicate isBarrier(DataFlow::Node barrier) { none() }

  predicate isAdditionalFlowStep(DataFlow::Node into, DataFlow::Node out) {
    // Extra taint step
    //     String.format("INSERT INTO users VALUES (%d, '%s')", id, info);
    // Not needed here, but may be needed for larger libraries.
    exists(MethodAccess ma | ma.getMethod().hasName("concat") |
      ma.getAnArgument() = into.asExpr() and
      ma = out.asExpr()
    )
  }

  predicate isSink(DataFlow::Node sink) {
    // conn.createStatement().executeUpdate(query);
    exists(Call exec |
      exec.getCallee().getName() = "executeUpdate" and
      exec.getArgument(0) = sink.asExpr()
    )
  }
}

module MyTaintTracking = TaintTracking::Make<MyTaintConfig>;

int explorationLimit() { result = 3 }

module MyFlowExploration = MyTaintTracking::FlowExploration<explorationLimit/0>;

import MyFlowExploration::PartialPathGraph

from MyFlowExploration::PartialPathNode source, MyFlowExploration::PartialPathNode dest
where MyFlowExploration::hasPartialFlow(source, dest, _)
select source, dest
