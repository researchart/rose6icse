package org.holmes.plugin.nodevisitor;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.eclipse.jdt.core.IJavaElement;
import org.eclipse.jdt.core.dom.ASTNode;
import org.eclipse.jdt.core.dom.ASTVisitor;
import org.eclipse.jdt.core.dom.Assignment;
import org.eclipse.jdt.core.dom.BooleanLiteral;
import org.eclipse.jdt.core.dom.CharacterLiteral;
import org.eclipse.jdt.core.dom.CompilationUnit;
import org.eclipse.jdt.core.dom.Expression;
import org.eclipse.jdt.core.dom.ExpressionStatement;
import org.eclipse.jdt.core.dom.IBinding;
import org.eclipse.jdt.core.dom.MethodDeclaration;
import org.eclipse.jdt.core.dom.MethodInvocation;
import org.eclipse.jdt.core.dom.NullLiteral;
import org.eclipse.jdt.core.dom.NumberLiteral;
import org.eclipse.jdt.core.dom.PrefixExpression;
import org.eclipse.jdt.core.dom.PrefixExpression.Operator;
import org.eclipse.jdt.core.dom.PrimitiveType;
import org.eclipse.jdt.core.dom.PrimitiveType.Code;
import org.eclipse.jdt.core.dom.SimpleName;
import org.eclipse.jdt.core.dom.Statement;
import org.eclipse.jdt.core.dom.StringLiteral;
import org.eclipse.jdt.core.dom.Type;
import org.eclipse.jdt.core.dom.VariableDeclaration;
import org.eclipse.jdt.core.dom.VariableDeclarationFragment;
import org.eclipse.jdt.core.dom.VariableDeclarationStatement;

public class TestMethodVisitor extends ASTVisitor {
	
	public char[] source;
	
	public boolean originalTest;
	
	// method call of interest
	public MethodInvocation methOfInterest;
	public Object paramOfInterest;
	public List<Object> paramsOfInterest;
	public Assignment assignOfInterest;
	public VariableDeclarationFragment fragOfInterest;
	
	// test method to find
	public String targetTestMethod;
	// method call of interest in target test method
	public String targetMethod;
	// line number of method call of interest
	public int lineNo; 
	
	// full test statement (for tool output)
	public String fullTest;
	public String originalFullTest;
	
	public boolean notLiteral = false;
	public boolean multiParam = false;
	
	// list of variables declared (in case needed to find value for test input)
	public List<VariableDeclarationFragment> declFragments;
	// list of values assigned to variables (in case needed to find value for test input)
	public List<Assignment> assignments;
	
	// list of statements in test
	String testStatements;

	public TestMethodVisitor() {
		
	}

	public TestMethodVisitor (char[] source, String targetMethod, String targetTestMethod, boolean original, int lineNo) {
		this.source = source;
		this.targetTestMethod = targetTestMethod;
		this.targetMethod = targetMethod;
		this.lineNo = lineNo;
		declFragments = new ArrayList<>();
		assignments = new ArrayList<>();
		originalTest = original;
		paramsOfInterest = new ArrayList<>();
	}
	
	/*
	 * (non-Javadoc)
	 * 
	 * This method visits all the variable declarations and saves them all.
	 * 
	 * @see org.eclipse.jdt.core.dom.ASTVisitor#visit(org.eclipse.jdt.core.dom.VariableDeclarationStatement)
	 */
	public boolean visit (VariableDeclarationFragment node) {
		declFragments.add(node);
		
		return true;
	}
	
	/*
	 * (non-Javadoc)
	 * 
	 * This method collects all assignments in the target test method
	 * @see org.eclipse.jdt.core.dom.ASTVisitor#visit(org.eclipse.jdt.core.dom.Assignment)
	 */
	public boolean visit (Assignment node) {
		
		MethodDeclaration methDec = getMethodDeclaration(node);

		if (methDec.getName().toString().equals(targetTestMethod)) {
			assignments.add(node);			
		}
		
		return true;
	}
	 
	public boolean visit (MethodInvocation node) {
		
		String methInv = node.getName().getFullyQualifiedName();
		
		MethodDeclaration methDec = getMethodDeclaration(node);
		String methodName = methDec.getName().toString();
		
		if (methDec != null) {		
			// this makes sure we're in the scope of right test method (which means it works for local but not global variables
			if (methInv.equals(targetMethod) && methodName.equals(targetTestMethod)) {
				
				methOfInterest = node;
				int lineNo = ((CompilationUnit) node.getRoot()).getLineNumber(node.getStartPosition());
				
				if (node.arguments().size() == 1) {
					if (lineNo == this.lineNo) {
						setSingleParamValues(node, methDec);											
					}
				} else {
					multiParam = true;
					
					if (lineNo == this.lineNo) {
						setMultiParamValues(node, methDec);
					}

				}
				
			}
			
		}
		
		
		return true;
	}

	private void setMultiParamValues(MethodInvocation node, MethodDeclaration methDec) {
		for (Object arg : node.arguments()) {
			if (arg instanceof SimpleName) {
				SimpleName nameParamOfInterest = (SimpleName) arg;
				
				for (int i=0; i < assignments.size(); i++) {
					
					if (i+1 == assignments.size()-1) {
						Assignment nextAssign = assignments.get(i+1);
						String nextAssignVariable = nextAssign.getLeftHandSide().toString();
						
						if (nextAssignVariable.equals(nameParamOfInterest.toString())) {
							if (originalTest) {
								originalFullTest = findFullTest(node).toString();
							}
							fullTest = findFullTest(node).toString();
							// add assignment to list of parameters
							paramsOfInterest.add(nextAssign);
						} 
					}				
				}
				
				if (assignOfInterest == null) {
					if (declFragments != null) {
						for (VariableDeclarationFragment frag: declFragments) {
							if (frag.getName().toString().equals(nameParamOfInterest.toString())) {
								// if not hard coded string, get the variable declaration with value
								paramsOfInterest.add(frag);	
							}
						}					
					}
				}				
			} else {
				if (arg instanceof StringLiteral || arg instanceof CharacterLiteral) {
					paramsOfInterest.add(arg);								
				} else if (arg instanceof PrefixExpression) {
					PrefixExpression param = (PrefixExpression) arg;
					
					paramsOfInterest.add(param);
				} else if (arg instanceof NumberLiteral) {
					NumberLiteral param = (NumberLiteral) arg;
					
					paramsOfInterest.add(param);
				} else if (arg instanceof BooleanLiteral) {
					BooleanLiteral param = (BooleanLiteral) arg;
				}
			}
		}
		
		if (originalTest) {
			originalFullTest = findFullTest(node).toString();
		}
		
		fullTest = findFullTest(node).toString();
		
		StringBuffer sb = new StringBuffer();
		
		for (Object param : paramsOfInterest) {
			sb.append(param.toString());
			sb.append("\n");
		}
		
		sb.append(fullTest);
		
		testStatements = sb.toString();
		
	}

	private void setSingleParamValues(MethodInvocation node, MethodDeclaration methDec) {
		if (node.arguments().get(0) instanceof SimpleName) {
			notLiteral = true;
			SimpleName nameParamOfInterest = (SimpleName) node.arguments().get(0);
			
			for (int i=0; i < assignments.size(); i++) {
//				Assignment assign = assignments.get(i);
//				int assignLineNo = ((CompilationUnit) assign.getRoot()).getLineNumber(assign.getStartPosition());
				
				if (i+1 == assignments.size()-1) {
					Assignment nextAssign = assignments.get(i+1);
					
					String nextAssignVariable = nextAssign.getLeftHandSide().toString();
					if (nextAssignVariable.equals(nameParamOfInterest.toString())) {
						if (originalTest) {
							originalFullTest = findFullTest(node).toString();
						}
						
						fullTest = findFullTest(node).toString();
						assignOfInterest = nextAssign;
						testStatements = assignOfInterest + "\n" + fullTest;
					} 
				}				
			}
			
			if (assignOfInterest == null) {
				if (declFragments != null) {
					for (VariableDeclarationFragment frag: declFragments) {
						if (frag.getName().toString().equals(nameParamOfInterest.toString())) {
							if (originalTest) {
								originalFullTest = findFullTest(node).toString();
							}
							
							fullTest = findFullTest(node).toString();
							fragOfInterest = frag;	
							testStatements = fragOfInterest + "\n" + fullTest;
						}
					}					
				}
			}

		} else {
			// if hardcoded value, get just gather test statement
			ExpressionStatement fullTest = findFullTest(node);
			
			if (fullTest != null) {
				if (originalTest) {
					originalFullTest = fullTest.toString();
				}
				
				this.fullTest = fullTest.toString();				
			}
			
			if (node.arguments().get(0) instanceof StringLiteral || node.arguments().get(0) instanceof CharacterLiteral) {
				paramOfInterest = node.arguments().get(0);				
				
			} else if (node.arguments().get(0) instanceof PrefixExpression) {
				// number with a sign
				PrefixExpression param = (PrefixExpression) node.arguments().get(0);
				
				paramOfInterest = param;
				
			} else if (node.arguments().get(0) instanceof NumberLiteral) {
				// handle numbers
				NumberLiteral numParam = (NumberLiteral) node.arguments().get(0);
				
				paramOfInterest = numParam;
								
			} else if (node.arguments().get(0) instanceof BooleanLiteral	) {
				BooleanLiteral boolParam = (BooleanLiteral) node.arguments().get(0);
				
				paramOfInterest = boolParam.booleanValue();
			} 
//			else if (node.arguments().get(0) instanceof NullLiteral) {
//						NullLiteral nullParam = (NullLiteral) node.arguments().get(0);
//						
//						paramOfInterest = null;
//					}
			
		}
	}
	
	private ExpressionStatement findFullTest(ASTNode node) {
		if (node.getParent() != null) {
			return node instanceof ExpressionStatement ? (ExpressionStatement)node : findFullTest(node.getParent());
		}
		
		return null;
	}
	
	public boolean getIsNotLiteral() {
		return notLiteral;
	}
	
	public boolean getIsMultiParam() {
		return multiParam;
	}
	
	public String getFullTest() {
		return fullTest;
	}
	
	public String getOriginalTest()	{
		return originalFullTest;
	}

	public String getTestStatements() {
		return testStatements;
	}
	
	public Object getParamOfInterest() {
		return paramOfInterest;
	}
	
	public List<Object> getParamsOfInterst(){
		return paramsOfInterest;
	}
	
	public VariableDeclarationFragment getFragOfInterest() {
		return fragOfInterest;
	}
	
	public MethodInvocation getFullMethod() {
		return methOfInterest;
	}
	
	public String getTargetTestMethod() {
		return targetTestMethod;
	}
	
	public String getTargetMethod() {
		return targetMethod;
	}
	
	protected String findSourceForNode(ASTNode node) {
		try {
			return new String(Arrays.copyOfRange(source, node.getStartPosition(), node.getStartPosition() + node.getLength()));
		}
		catch (Exception e) {
			System.err.println("OMG PROBLEM MAKING SOURCE FOR "+node);
			return "";
		}
	}
	
	private MethodDeclaration getMethodDeclaration(ASTNode node) {
		if (node.getParent() != null){
			return node instanceof MethodDeclaration ? (MethodDeclaration)node : getMethodDeclaration(node.getParent());			
		}
		
		return null;
	}

}
