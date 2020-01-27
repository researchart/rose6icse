package org.holmes.plugin.nodevisitor;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.eclipse.jdt.core.dom.ASTNode;
import org.eclipse.jdt.core.dom.ASTVisitor;
import org.eclipse.jdt.core.dom.Assignment;
import org.eclipse.jdt.core.dom.BooleanLiteral;
import org.eclipse.jdt.core.dom.CastExpression;
import org.eclipse.jdt.core.dom.CharacterLiteral;
import org.eclipse.jdt.core.dom.Expression;
import org.eclipse.jdt.core.dom.ExpressionStatement;
import org.eclipse.jdt.core.dom.MethodDeclaration;
import org.eclipse.jdt.core.dom.MethodInvocation;
import org.eclipse.jdt.core.dom.NullLiteral;
import org.eclipse.jdt.core.dom.NumberLiteral;
import org.eclipse.jdt.core.dom.ParenthesizedExpression;
import org.eclipse.jdt.core.dom.PrefixExpression;
import org.eclipse.jdt.core.dom.SimpleName;
import org.eclipse.jdt.core.dom.Statement;
import org.eclipse.jdt.core.dom.StringLiteral;
import org.eclipse.jdt.core.dom.Type;
import org.eclipse.jdt.core.dom.VariableDeclarationFragment;
import org.eclipse.jdt.core.dom.VariableDeclarationStatement;

public class GeneratedTestVisitor extends ASTVisitor {
	
	public char[] source;
	
	// method call of interest
	public String targetMethod;
	
	// store generated inputs for single param method
	public List<Object> newInputs;
	// store generated inputs for multi parameter method
	public List<Object> newMultiInputs;
	
	List<VariableDeclarationStatement> declStatements;
	HashMap<String, Assignment> assignments;	
	
	public boolean notStringLiteral = false;
	public boolean isMultiParam = false;
	
	// list of statements in test
	String testStatements;
	
	// full test 
	String fullTest;
	
	public Object genParamOfInterest;
	public List<Object> genParamsOfInterest;
	
	public GeneratedTestVisitor() {
		
	}
	
	public GeneratedTestVisitor(char[] source, String targetMethod) {
		this.source = source;
		this.targetMethod = targetMethod;
		newInputs = new ArrayList<Object>();
		newMultiInputs = new ArrayList<>();
		declStatements = new ArrayList<VariableDeclarationStatement>();
		assignments = new HashMap<String, Assignment>();
		genParamsOfInterest = new ArrayList<>();
	}
	
	public boolean visit (VariableDeclarationStatement node) {
		declStatements.add(node);
		
		return true;
	}
	
	public boolean visit (Assignment node) {
		MethodDeclaration methDec = getMethodDeclaration(node);
		
		assignments.put(methDec.getName().toString(), node);
		
		return true;
	}
	
	public boolean visit (MethodInvocation node) {
		
		String methInv = node.getName().getFullyQualifiedName();
		
		MethodDeclaration methDec = getMethodDeclaration(node);
		String methodName = methDec.getName().toString();
		
		if (methInv.equals(targetMethod)) {
//			System.out.println("Test calling target method --> " + findSourceForNode(node));
			
			List params = node.arguments();
			
			if (params.size() == 1) {
				setSingleParamValues(node, methDec, params);
			} else {
				isMultiParam = true;
				setMultiParamValues(node, methDec, params);
			}
			
			
		}
		
		return true;
	}
	
	private void setMultiParamValues(MethodInvocation node, MethodDeclaration methDec, List params) {
		Object fullTest = findFullTest(node);

		if (fullTest != null) {
			this.fullTest = fullTest.toString();
		}
		// get parent (test) method that calls target method 
		MethodDeclaration targetMethodDeclaration = getMethodDeclaration(node);
		String targetMethodDeclarationName = targetMethodDeclaration.getName().toString();
		
		List<Object> genParamsOfInterest = new ArrayList<>();
		
		for (Object param : params) {
			if (param instanceof SimpleName) {
				SimpleName nameGenParam = (SimpleName) param;
//				System.out.println(nameGenParam.getParent().toString());
				
				// first check assignments
				Iterator it = assignments.entrySet().iterator();
				
				while (it.hasNext()) {
					Map.Entry pair = (Map.Entry) it.next();
					String currentMethDeclName = (String) pair.getKey();
					Assignment assignment = (Assignment) pair.getValue();
					
					// check if parent method of assignment same as target method invocation
					if (currentMethDeclName.equals(targetMethodDeclarationName)) {
						// add assignment to list of generated params for this method call
						genParamsOfInterest.add(assignment);
					}
				}
				
				// check if size of genParams matches params (to see if need to even go through declarations)
				if (genParamsOfInterest.size() < params.size()) {
					if (declStatements != null) {
						for (VariableDeclarationStatement stmt : declStatements) {
							MethodDeclaration currentMethDecl = getMethodDeclaration(stmt);
							String currentMethDeclName = currentMethDecl.getName().toString();
							String varName = "";
							
							// parent method of fragment is same as parent method of invocation (in same method)
							if (currentMethDeclName.equals(targetMethodDeclarationName)) {
								for (Object frag : stmt.fragments()) {
									VariableDeclarationFragment varFrag = (VariableDeclarationFragment) frag;
									varName = varFrag.getName().toString();
									
									if (varName.equals(nameGenParam.toString())) {
										genParamsOfInterest.add(stmt);
									}
								}
													
							}
						}											
					}
				}
				
			} else {
				if (param instanceof StringLiteral || param instanceof CharacterLiteral) {
					genParamsOfInterest.add(param);
				} else if (param instanceof CastExpression) {
					// TODO this may not properly handle cast to object rather than primitive
					CastExpression genParam = (CastExpression) param;
					
					genParamsOfInterest.add(genParam);
										
				} else if (param instanceof PrefixExpression) {
					PrefixExpression genParam = (PrefixExpression) param;
					
					genParamsOfInterest.add(genParam);
					
				} else if (param instanceof NumberLiteral) {
					NumberLiteral genParam = (NumberLiteral) param;
					
					genParamsOfInterest.add(genParam);
				} else if (param instanceof BooleanLiteral) {
					BooleanLiteral genParam = (BooleanLiteral) param;
					
					genParamsOfInterest.add(genParam);
				} else if (param instanceof NullLiteral) {
					NullLiteral genParam = (NullLiteral) param;
					
					genParamsOfInterest.add(genParam);
				} else if (param instanceof ParenthesizedExpression) {
					ParenthesizedExpression genParam = (ParenthesizedExpression) param;
					
					genParamsOfInterest.add(genParam);
				}
			}
		}
		newMultiInputs.add(genParamsOfInterest);
		
		
	}

	private void setSingleParamValues(MethodInvocation node, MethodDeclaration methDec, List params) {
		ExpressionStatement fullTest = (findFullTest(node));
		if (fullTest != null) {
			this.fullTest = fullTest.toString();
		}
		
		// get parent (test) method that calls target method 
		MethodDeclaration targetMethodDeclaration = getMethodDeclaration(node);
		String targetMethodDeclarationName = targetMethodDeclaration.getName().toString();
		
		Object param = params.get(0);
		
		if (param instanceof SimpleName) {
			
			SimpleName nameGenParam = (SimpleName) param;
//			System.out.println(nameGenParam.getParent().toString());
			
			// first check assignments
			Iterator it = assignments.entrySet().iterator();
			
			while (it.hasNext()) {
				Map.Entry pair = (Map.Entry) it.next();
				String currentMethDeclName = (String) pair.getKey();
				Assignment assignment = (Assignment) pair.getValue();
				
				// check if parent method of assignment same as target method invocation
				if (currentMethDeclName.equals(targetMethodDeclarationName)) {
					// add assignment to list of generated params for this method call
					genParamOfInterest = assignment;
				}
			}
			
			// check if size of genParams matches params (to see if need to even go through declarations)
			if (genParamOfInterest == null) {
				if (declStatements != null) {
					for (VariableDeclarationStatement stmt : declStatements) {
						MethodDeclaration currentMethDecl = getMethodDeclaration(stmt);
						String currentMethDeclName = currentMethDecl.getName().toString();
						String varName = "";
						
						// parent method of fragment is same as parent method of invocation (in same method)
						if (currentMethDeclName.equals(targetMethodDeclarationName)) {
							for (Object frag : stmt.fragments()) {
								VariableDeclarationFragment varFrag = (VariableDeclarationFragment) frag;
								varName = varFrag.getName().toString();
								
								if (varName.equals(nameGenParam.toString())) {
									genParamOfInterest = stmt;
								}
							}
												
						}
					}											
				}
			}
		} else {

			if (param instanceof StringLiteral || param instanceof CharacterLiteral) {
				genParamOfInterest = param;
				
			} else if (param instanceof NumberLiteral) {
				// numbers
				NumberLiteral genNumParam = (NumberLiteral) param;
				
				genParamOfInterest = genNumParam;
				
			} else if (param instanceof BooleanLiteral) {
				// boolean
				BooleanLiteral genBoolParam = (BooleanLiteral) param;
				
				genParamOfInterest = genBoolParam;
				
			} else if (param instanceof NullLiteral) {
				NullLiteral genNullParam = (NullLiteral) param;
				
				genParamOfInterest = genNullParam;
			}
			
			
			newInputs.add(genParamOfInterest);
		}
	}
	
	public boolean getIsMultiParam() {
		return isMultiParam;
	}
	
	public List<Object> getGeneratedSingleParamInputs() {
		return newInputs;
	}
	
	public List<Object> getGeneratedMultiParamInputs(){
		return newMultiInputs;
	}
	
	public Object getGenParamOfInterest() {
		return genParamOfInterest;
	}
	
	public List<Object> getGenParamsOfInterest(){
		return genParamsOfInterest;
	}
	
	private ExpressionStatement findFullTest(ASTNode node) {
		if (node.getParent() != null) {
			return node instanceof ExpressionStatement ? (ExpressionStatement)node : findFullTest(node.getParent());
		}
		
		return null;
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
