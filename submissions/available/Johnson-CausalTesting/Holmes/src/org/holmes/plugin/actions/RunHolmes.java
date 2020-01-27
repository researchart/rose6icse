package org.holmes.plugin.actions;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import org.apache.commons.exec.CommandLine;
import org.apache.commons.exec.DefaultExecutor;
import org.apache.commons.exec.ExecuteException;
import org.apache.commons.exec.PumpStreamHandler;
import org.apache.commons.io.FileUtils;
import org.apache.commons.text.similarity.LevenshteinDetailedDistance;
import org.apache.commons.text.similarity.LevenshteinResults;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.jdt.core.IClasspathEntry;
import org.eclipse.jdt.core.ICompilationUnit;
import org.eclipse.jdt.core.IJavaElement;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.core.ITypeRoot;
import org.eclipse.jdt.core.JavaCore;
import org.eclipse.jdt.core.JavaModelException;
import org.eclipse.jdt.core.dom.AST;
import org.eclipse.jdt.core.dom.ASTParser;
import org.eclipse.jdt.core.dom.Assignment;
import org.eclipse.jdt.core.dom.BooleanLiteral;
import org.eclipse.jdt.core.dom.CastExpression;
import org.eclipse.jdt.core.dom.CharacterLiteral;
import org.eclipse.jdt.core.dom.CompilationUnit;
import org.eclipse.jdt.core.dom.Expression;
import org.eclipse.jdt.core.dom.MethodInvocation;
import org.eclipse.jdt.core.dom.NumberLiteral;
import org.eclipse.jdt.core.dom.ParenthesizedExpression;
import org.eclipse.jdt.core.dom.PrefixExpression;
import org.eclipse.jdt.core.dom.PrefixExpression.Operator;
import org.eclipse.jdt.core.dom.SimpleName;
import org.eclipse.jdt.core.dom.StringLiteral;
import org.eclipse.jdt.core.dom.Type;
import org.eclipse.jdt.core.dom.VariableDeclarationFragment;
import org.eclipse.jdt.core.dom.VariableDeclarationStatement;
import org.eclipse.jdt.core.dom.rewrite.ASTRewrite;
import org.eclipse.jdt.internal.ui.javaeditor.CompilationUnitEditor;
import org.eclipse.jdt.internal.ui.javaeditor.EditorUtility;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.Document;
import org.eclipse.jface.text.ITextSelection;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.text.edits.TextEdit;
import org.eclipse.ui.IEditorActionDelegate;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.IViewPart;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.PlatformUI;
import org.holmes.plugin.nodevisitor.GeneratedTestVisitor;
import org.holmes.plugin.nodevisitor.TestMethodVisitor;
import org.holmes.plugin.util.Test;

public class RunHolmes implements IEditorActionDelegate {
	private IWorkbenchWindow window = PlatformUI.getWorkbench().getActiveWorkbenchWindow();
	private IEditorPart editor = PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage().getActiveEditor();
	private IWorkbenchPage page = window.getActivePage();
	
	public File workingDirectory = new File ("/Users/bjohnson/Documents/Research_2019-2020/causal_testing/Holmes/");
	
	public String testGenJar = workingDirectory.getPath() + "/lib/evosuite-1.0.6.jar";
	
	public String packageNameStart = "org";
	public File inputFile;
	
	public Object input;
	
	File binInstrumentedTestDir;
	File binInstrumentedDepDir;
	
	
	IFile testFile;
	Document testDocument;
	ICompilationUnit icu;
	AST ast;
	CompilationUnit cu;
	ASTParser parser;
		
	// parameter from single method parameter call
	Object currentParam;
	// parameters from multi-parameter method call
	List<Object> currentParams = new ArrayList<>();
	
	boolean isMultiParam;
	
	Test targetTest;
	IProject targetProject;
	String targetProjectName;
	
	List<IFile> filesToExport = new ArrayList<>();
	
	List<String> passingTests = new ArrayList<>(); 
	List<String> failingTests = new ArrayList<>();
	
	// store input closest to original found in generated tests
	String closestGeneratedInput;
	// store inputs closest to original for multi-param
//	List<String> closestGeneratedInputs;
	HashMap<String, List<String>> closestGeneratedInputs = new HashMap<>();
	
	List<Object> executedInputs = new ArrayList<>();
	
	List<String> fuzzedValues = new ArrayList<>();;
	
	HashMap<String[], Integer> editDistances = new HashMap<String[], Integer>();
	List<String> distanceResults = new ArrayList<String>();
	
	String[] srcDirectory;
	String[] classpath;
	

	@Override
	public void run(IAction arg0) {
		
//		IViewPart view;
//		try {
//			view = PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage().showView("org.holmes.plugin.views.HolmesView");
//			PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage().hideView(view);
//		} catch (PartInitException e2) {
//			e2.printStackTrace();
//		}

		// File of interest
		IEditorInput input = editor.getEditorInput();
		testFile = ((IFileEditorInput)input).getFile();
		
		// get selected method & line number
		CompilationUnitEditor editor = (CompilationUnitEditor)this.editor;
		ITextSelection selection = getSelection(editor);
		int lineNo = selection.getStartLine() +1;
		String selectedMethod = selection.getText();

		System.out.println("Line number = " + lineNo);
		System.out.println("The method under test is: " + selectedMethod);
		
		// create test object
		targetTest = new Test(testFile.getName());
		targetProjectName = testFile.getProject().getName();
		
		//if training defect, run the rest
		
		if (targetProjectName.equals("Defect_0_Training")) {
			runFullProcess(selection, lineNo, selectedMethod);			
		} 
		
		try {
			IViewPart output = PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage().showView("org.holmes.plugin.views.HolmesView");
			
			PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage().hideView(output);
			TimeUnit.SECONDS.sleep(3);
			
			PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage().showView("org.holmes.plugin.views.HolmesView");				
			
		} 
		catch (InterruptedException e) {
			
			e.printStackTrace();
		} 
		catch (PartInitException e) {
			e.printStackTrace();
		}


	}


	private void runFullProcess(ITextSelection selection, int lineNo, String selectedMethod) {
		// create compilation unit from test file
		icu = JavaCore.createCompilationUnitFrom(testFile);
		
		// directory where source project is located (working directory for test generation)
		File executorDirectory = new File(workingDirectory.getPath() + "/" + testFile.getProject().getName());
		
		
		try {
			// creation of document containing source code			
			String source = icu.getSource();
			testDocument = new Document(source);
			
			// find source directory
			File baseClassDir;
			
			if ((new File(executorDirectory.getPath() + "/bin/").exists())){
				baseClassDir = new File(executorDirectory.getPath() + "/bin/");
			} else {
				baseClassDir = new File(executorDirectory.getPath() + "/target/classes");
			}
			File srcDir;
			
			if ((new File(executorDirectory.getPath() + "/src").exists())) {
				srcDir = new File(executorDirectory.getPath() + "/src/");
				
			} else {
				srcDir = new File(executorDirectory.getPath() + "/source/");
			}
			
			//get Java project for type bindings
			IProject currentProject = testFile.getProject();
			IJavaProject javaProject = JavaCore.create(currentProject);
			
			if (javaProject.exists()) {
				System.out.println("Java project found!");
				
				classpath = getClasspath(javaProject);	
				srcDirectory = new String[] {srcDir.getPath()};
				
				// create and set up ASTParser (with source directory and classpath)
				updateASTParser();
				
			} else {
				System.out.println("No java projects found!");
			}
			
			// get parameter of interest
			getParamOfInterest(selection, lineNo, selectedMethod, executorDirectory, source);
			 
			System.out.println("\nTest file: " + targetTest.getFilename()); 
			System.out.println("Project: " + targetProjectName);
			System.out.println("Test method: " + targetTest.getTestMethod());
			System.out.println("Target method: " + targetTest.getTargetMethod());
			
			if (targetTest.getOriginalParameter() == null) {
				isMultiParam = true;
				System.out.println("Original test parameters: ");
				for (String s : targetTest.getOriginalParameters()) {
					System.out.println(s);
				}
			} else {
				isMultiParam = false;
				System.out.println("Original test parameter: " + targetTest.getOriginalParameter());
			}
		
			System.out.println("Full test: " + targetTest.getFullTest() + "\n");
			
			// write original test to file to pipe to view later
//			writeOriginalTestToFile(workingDirectory.getPath()+"/holmes-output-original.txt");
			writeOriginalTestToFile(workingDirectory.getAbsolutePath() + "/holmes-output-original.txt");
			
			String testFile = this.testFile.getName();
			String fileUnderTest = testFile.substring(0, testFile.indexOf("Test"));
			String targetFilePackage = "";
			String classDir = baseClassDir.getAbsolutePath();
			
			// find file under test
			boolean recursive = true;
			Collection files = FileUtils.listFiles(srcDir, null, recursive);
			
			for (Iterator i = files.iterator(); i.hasNext();) {
				File f = (File) i.next();
				
				// only check files that are java files 
				if (f.getName().contains(".java")) {
					
					String className = f.getName().substring(0, f.getName().indexOf(".java"));
					
					// check if target file; if so, store necessary information
					if (className.equals(fileUnderTest)) {
						System.out.println("Path to target file = " + f.getAbsolutePath());
						
						File targetFileDir = new File (f.getAbsolutePath());
						String pathToFile = targetFileDir.getAbsolutePath();
						targetFilePackage = pathToFile.substring(pathToFile.indexOf("org"), pathToFile.length()-5).replace("/", ".");
						
						String targetFileDirectory = targetFilePackage.substring(0, targetFilePackage.lastIndexOf("."));
						classDir = baseClassDir + "/" + targetFileDirectory.replace(".", "/");
												
						System.out.println("Working directory = " + executorDirectory.getPath());
						System.out.println("File package = " + targetFilePackage);
						System.out.println("Class file directory = " + classDir);
						
					}
				}
			}
			
			/* 
			 * RUN EVOSUITE
			 */
			
//			runEvoSuite(executorDirectory, targetFilePackage, baseClassDir.getAbsolutePath());
			
			/*
			 * PARSE TESTS FOR INPUTS
			 */
			
			List<String> evoGeneratedInputs = new ArrayList<>();
			String targetMethod = targetTest.getTargetMethod();
			System.out.println(targetMethod);
			
			// directory with tests
			targetFilePackage = targetFilePackage.substring(0, targetFilePackage.lastIndexOf("."));
			File evoTestsDir = new File(executorDirectory.getAbsolutePath() + "/evosuite-tests/" + targetFilePackage.replace(".", "/"));
			System.out.println(evoTestsDir.getAbsolutePath());
			
			// find and parse files in directory
			File[] testFiles = evoTestsDir.listFiles();
		
			parseGeneratedTests(targetMethod, testFiles);
			
			if (isMultiParam) {
			System.out.println("\n Original parameters are --> " + targetTest.getOriginalParameters());
			} else {
				System.out.println("\n Original parameter is --> " + targetTest.getOriginalParameter());
				
			}
		
			
			/*
			 * RUN INPUT FUZZERS
			 */
			
			String cmdLineArg = "";
			
			// Run fuzzers with original input(s)
			// TODO update to iterate over currentParams (Literal, Decls, Assigns) not originalParameters (Strings) 
			if (isMultiParam) {				
				List<String> params = targetTest.getOriginalParameters();
				
				for (int i=0; i < params.size(); i++) {
					String param = params.get(i);
					
					if (param.contains("=")) {
						cmdLineArg = param.substring(param.indexOf("="), param.indexOf(";")).replaceAll("\"", "");
					} else {
						cmdLineArg = params.get(i).replaceAll("\"", "");						
					}
					
					System.out.println("Input to fuzz --> " + cmdLineArg);
					
					String fileId = Integer.toString(i);
					runFuzzers(cmdLineArg, true, fileId);
				}
			} else {
				cmdLineArg = targetTest.getOriginalParameter().replaceAll("\"", "");
				System.out.println("Input to fuzz --> " + cmdLineArg);
				
				runFuzzers(cmdLineArg, true, "1");
			}
			
			// Run fuzzers with generated input(s)
			Iterator it = closestGeneratedInputs.entrySet().iterator();
			
			// iterate over each parameter (will only be multiple iterations if multiple parameters)
			int param_count = 0;
			while (it.hasNext()) {
				Map.Entry<String, List<String>> pair = (Map.Entry<String, List<String>>) it.next();
				List<String> genParams = pair.getValue();
				List<String> noDups = new ArrayList<>(new HashSet<>(genParams));
				
				for (int i=0; i < noDups.size(); i++) {
					cmdLineArg = noDups.get(i).replaceAll("\"", "");
					System.out.println("Input to fuzz --> " + cmdLineArg);
					
					String paramId = Integer.toString(param_count);
					String fileId = Integer.toString(i);
					runFuzzers(cmdLineArg, false, paramId+ "_"+ fileId);
				}				
				
				param_count ++;
			}
			
			/*
			 * PARSE FUZZER OUTPUT & EXECUTE TESTS
			 */
			
			// parse original mutation files
			if (isMultiParam) {
				List<String> originalParams = targetTest.getOriginalParameters();
				for (int i=0; i<originalParams.size(); i++) {
					String fileId = Integer.toString(i);
					
					File original_fuzzed = new File(workingDirectory.getPath() + "/fuzzers/fuzzer_results_original_" + fileId + ".txt");
					
					if (original_fuzzed.exists()) {
						BufferedReader br = new BufferedReader(new FileReader(original_fuzzed));
						
						int threshold = 2;
						int paramPlace = i;
						
						updateAndRunTest(lineNo, executorDirectory, originalParams, i, br, threshold, paramPlace, false);
					}
					
				} 
			} else {
				File original_fuzzed = new File(workingDirectory.getPath() + "/fuzzers/fuzzer_results_original_1.txt");
				
				String original = targetTest.getOriginalParameter();
				
				if (original_fuzzed.exists()) {
					
					BufferedReader br = new BufferedReader(new FileReader(original_fuzzed));
					
					int threshold = 2;
					
					//create list to store original param for updateAndRunTest (TODO: refactor) 
					List<String> originalParams = new ArrayList<>();
					originalParams.add(original);
					
					updateAndRunTest(lineNo, executorDirectory, originalParams, 0, br, threshold, 0, false);

				}
				
			}
			
			// parse generated mutation files
			Iterator it2 = closestGeneratedInputs.entrySet().iterator();
			
			// iterate over each parameter (will only be multiple iterations if multiple parameters)
			int param_num = 0; 
			
			while (it.hasNext()) {
				
				Map.Entry<String, List<String>> pair = (Map.Entry<String, List<String>>) it.next();
				
				List<String> genParams = pair.getValue();
				
				for (int i=0; i<genParams.size(); i++) {
					String fileId = Integer.toString(i);
					
					File generated_fuzzed = new File(workingDirectory.getPath() + "/fuzzers/fuzzer_results_generated_" + param_num + "_" + fileId);
					
					if (generated_fuzzed.exists()) {
						BufferedReader br = new BufferedReader(new FileReader(generated_fuzzed));
						
						String line = "";
						int threshold = 2;
						int distance = 0;
						int paramPlace = i;
						
						updateAndRunTest(lineNo, executorDirectory, genParams, i, br, threshold, paramPlace, false);
					}
				}
				
				param_num++;
				
			}

		
			writeOutputFile();
			
			// Restore original parameter(s)
			if (isMultiParam) {
				// TODO 
			} else {
				List<String> param = new ArrayList<>();
				param.add(targetTest.getOriginalParameter()); 
				updateAndRunTest(0, executorDirectory, param, 0, new BufferedReader(new FileReader(workingDirectory.getAbsolutePath() + "/holmes-output-original.txt")), 2, 0, true);				
			}
			
			
			
			
		} catch (JavaModelException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} 
//		catch (ExecuteException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		} 		 
		catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (BadLocationException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	
	private void updateAndRunTest(int lineNo, File executorDirectory, List<String> originalParams, int i,
			BufferedReader br, int threshold, int paramPlace, boolean last)
			throws IOException, BadLocationException, JavaModelException, InterruptedException, ExecuteException {
		
		String line;
		int distance;
		
		if (last) {
			updateTestInput(0, originalParams.get(0));
			savePage(page);
		} else {
			while ((line = br.readLine() )!= null) {
				
				if ((failingTests.size() < 3 && passingTests.size() < 3)) {
					// find inputs within threshold and run
					if (isValidNumber(line)) {
						Object oldNum = determineNumType(originalParams.get(i));
						Object newNum = determineNumType(line);
						
						// check if generated/fuzzed input same type as original (so compiles and runs)
						if (oldNum instanceof Integer && newNum instanceof Integer) {
							Integer originalNum = (Integer) oldNum;
							Integer fuzzNum = (Integer) newNum;
							
							// see how close fuzzed input is from original
							distance = Math.abs(originalNum.intValue()-fuzzNum.intValue());
							
							// if difference is within threshold, run test with that input
							if (distance > 0 && distance <= threshold) {
								
								executedInputs.add(fuzzNum);
								
								// update and save page
								updateTestInput(paramPlace, fuzzNum);
								savePage(page);
								
								// wait for build to finish before running test
								TimeUnit.SECONDS.sleep(2);
								
								// update AST parser
								updateASTParser();
								getMethodParameters(testDocument.get(), targetTest.getTargetMethod(), targetTest.getTestMethod(), false, lineNo);
								
								// D4J compile
								d4jCompile(executorDirectory); 
								
								// D4J test
								d4jTest(executorDirectory);
							}
							
						} else if (oldNum instanceof Double && newNum instanceof Double) {
							Double originalNum = (Double) oldNum;
							Double fuzzNum = (Double) newNum;
							
							distance = (int) Math.abs(originalNum.doubleValue()-fuzzNum.doubleValue());
							
							if (distance > 0 && distance <= threshold) {
								
								executedInputs.add(fuzzNum);
								
								// update and save page
								updateTestInput(paramPlace, fuzzNum);
								savePage(page);
								
								// wait for build to finish before running test
								TimeUnit.SECONDS.sleep(2);
								
								// update AST parser
								updateASTParser();
								getMethodParameters(testDocument.get(), targetTest.getTargetMethod(), targetTest.getTestMethod(), false, lineNo);
								
								// D4J compile
								d4jCompile(executorDirectory); 
								
								// D4J test
								d4jTest(executorDirectory);
							}
							
						} else if (oldNum instanceof Float && newNum instanceof Float) {
							Float originalNum = (Float) oldNum;
							Float fuzzNum = (Float) newNum;
							
							distance = (int) Math.abs(originalNum.floatValue()-fuzzNum.floatValue());
							
							if (distance > 0 && distance <= threshold) {
								
								executedInputs.add(fuzzNum);
								
								// update and save page
								updateTestInput(paramPlace, fuzzNum);
								savePage(page);
								
								// wait for build to finish before running test
								TimeUnit.SECONDS.sleep(2);
								
								// update AST parser
								updateASTParser();
								getMethodParameters(testDocument.get(), targetTest.getTargetMethod(), targetTest.getTestMethod(), false, lineNo);
								
								// D4J compile
								d4jCompile(executorDirectory); 
								
								// D4J test
								d4jTest(executorDirectory);
							}
							
							
						} else if(oldNum instanceof Long && newNum instanceof Long) {
							Long originalNum = (Long) oldNum;
							Long fuzzNum = (Long) newNum;
							
							distance = (int) Math.abs(originalNum.longValue()-fuzzNum.longValue());
							
							if (distance > 0 && distance <= threshold) {
								
								executedInputs.add(fuzzNum);
								
								// update and save page
								updateTestInput(paramPlace, fuzzNum);
								savePage(page);
								
								// wait for build to finish before running test
								TimeUnit.SECONDS.sleep(2);
								
								// update AST parser
								updateASTParser();
								getMethodParameters(testDocument.get(), targetTest.getTargetMethod(), targetTest.getTestMethod(), false, lineNo);
								
								// D4J compile
								d4jCompile(executorDirectory); 
								
								// D4J test
								d4jTest(executorDirectory);
							}
							
							
						} else if (oldNum instanceof BigInteger && newNum instanceof BigInteger) {
							BigInteger originalNum = (BigInteger) oldNum;
							BigInteger fuzzNum = (BigInteger) newNum;
							
							distance = Math.abs(originalNum.intValue()-fuzzNum.intValue());
							
							if (distance > 0 && distance <= threshold) {
								
								executedInputs.add(fuzzNum);
								
								// update and save page
								updateTestInput(paramPlace, fuzzNum);
								savePage(page);
								
								// wait for build to finish before running test
								TimeUnit.SECONDS.sleep(2);
								
								// update AST parser
								updateASTParser();
								getMethodParameters(testDocument.get(), targetTest.getTargetMethod(), targetTest.getTestMethod(), false, lineNo);
								
								// D4J compile
								d4jCompile(executorDirectory); 
								
								// D4J test
								d4jTest(executorDirectory);
							}
							
						} else if (oldNum instanceof BigDecimal && newNum instanceof BigDecimal) {
							BigDecimal originalNum = (BigDecimal) oldNum;
							BigDecimal fuzzNum = (BigDecimal) newNum;
							
							distance = (int) Math.abs(originalNum.floatValue()-fuzzNum.floatValue());
							
							if (distance > 0 && distance <= threshold) {
								
								executedInputs.add(fuzzNum);
								
								// update and save page
								updateTestInput(paramPlace, fuzzNum);
								savePage(page);
								
								// wait for build to finish before running test
								TimeUnit.SECONDS.sleep(2);
								
								// update AST parser
								updateASTParser();
								getMethodParameters(testDocument.get(), targetTest.getTargetMethod(), targetTest.getTestMethod(), false, lineNo);
								
								// D4J compile
								d4jCompile(executorDirectory); 
								
								// D4J test
								d4jTest(executorDirectory);
							}
						}
					} else {
						if (!line.startsWith("FuzzManager")) {
							String oldString = originalParams.get(i);
							String fuzzString = line;
							
							distance = levenshteinDistance(oldString, fuzzString);
							
							if (distance > 0 && distance <= threshold) {
								
								executedInputs.add(fuzzString);
								
								// update and save page
								updateTestInput(paramPlace, fuzzString);
								savePage(page);
								
								// wait for build to finish before running test
								TimeUnit.SECONDS.sleep(2);
								
								// update AST parser
								updateASTParser();
								getMethodParameters(testDocument.get(), targetTest.getTargetMethod(), targetTest.getTestMethod(), false, lineNo);
								
								// D4J compile
								d4jCompile(executorDirectory); 
								
								// D4J test
								d4jTest(executorDirectory);
							}
							
						}
					}
				}
			}
			
		}
		
	}

	private String[] getClasspath(IJavaProject javaProject) throws JavaModelException {
		IClasspathEntry[] rawClassPath = javaProject.getRawClasspath();
		String[] classpathEntries = new String[rawClassPath.length];
		
		for (int i=0; i < rawClassPath.length; i++) {
			classpathEntries[i] = rawClassPath[i].toString();
		}
		
		IJavaElement element = JavaCore.create(testFile);
		ICompilationUnit icu = (ICompilationUnit) element;
		return classpathEntries;
	}

	private void getParamOfInterest(ITextSelection selection, int lineNo, String selectedMethod, File executorDirectory,
			String source) throws JavaModelException {
		boolean first = true;
		
		// get test method of selected method
		int selectionOffset = selection.getOffset();
		ITypeRoot root = EditorUtility.getEditorInputJavaElement(this.editor, false);
		IJavaElement selectedElement =  root.getElementAt(selectionOffset);
		
		String targetTestMethod = selectedElement.getElementName();	
		
		// pass target method into visitor to get test method and other relevant parts 
		getMethodParameters(source, selectedMethod, targetTestMethod, first, lineNo);
		
		targetTest.setTargetMethod(selectedMethod);
		
	}
	
	private String updateTestInput(int paramPlace, Object param)
			throws BadLocationException, JavaModelException {
		
		// Creation of ASTRewrite
		ASTRewrite rewrite = ASTRewrite.create(ast);
		String newSource = null;
		 
		if (isMultiParam) {
			for (int i=0; i<targetTest.getOriginalParameters().size(); i++) {
				
				Object current = currentParams.get(i);
				
				// see if original was a variable declaration or assignment so we know what to create/update
				if (current instanceof VariableDeclarationStatement) {
					VariableDeclarationStatement stmt = (VariableDeclarationStatement) current;
					
					String type = stmt.getType().toString();
					
					if (type.equals("boolean")) {
						BooleanLiteral newParam;
						
						if ((boolean) current) {
							newParam = ast.newBooleanLiteral(false);					
						} else {
							newParam = ast.newBooleanLiteral(true);
						}
						
						newSource = replaceVariableDeclaration(rewrite, newParam, type);
						
					} else if (type.equals("String")) {
						StringLiteral newParam = ast.newStringLiteral();
						newSource = replaceVariableDeclaration(rewrite, newParam, type);
						
					} else if (type.equals("int") || type.equals("float") || type.equals("double")|| type.equals("short")
							|| type.equals("long")) {
						NumberLiteral newParam = ast.newNumberLiteral();
						newSource = replaceVariableDeclaration(rewrite, newParam, type);
						
					}
					
				} else if (current instanceof Assignment) {
					// TODO
				} else {
					// Literals
					newSource = replaceASTLiteral(rewrite, paramPlace, param);
				}
			}
		} else {
			if (currentParam instanceof VariableDeclarationStatement) {
				VariableDeclarationStatement stmt = (VariableDeclarationStatement) currentParam;
				
				String type = stmt.getType().toString();
				
				if (type.equals("boolean")) {
					BooleanLiteral newParam;
					
					if ((boolean) currentParam) {
						newParam = ast.newBooleanLiteral(false);					
					} else {
						newParam = ast.newBooleanLiteral(true);
					}
					
					newSource = replaceVariableDeclaration(rewrite, newParam, type);
					
				} else if (type.equals("String")) {
					StringLiteral newParam = ast.newStringLiteral();
					newSource = replaceVariableDeclaration(rewrite, newParam, type);
					
				} else if (type.equals("int") || type.equals("float") || type.equals("double")|| type.equals("short")
						|| type.equals("long")) {
					NumberLiteral newParam = ast.newNumberLiteral();
					newSource = replaceVariableDeclaration(rewrite, newParam, type);
					
				}
					
			} else if (currentParam instanceof Assignment) {
				// TODO
			} else {
				
				newSource = replaceASTLiteral(rewrite, paramPlace, param);
			}
		}
		
		return newSource;

	}
	
	private String replaceASTLiteral(ASTRewrite rewrite, int paramPlace, Object param)
			throws BadLocationException, JavaModelException {
		
		String newSource = "";
		
		if (isMultiParam) {
			// get current params
			for (int i=0; i<currentParams.size(); i++) {
				
				Object current = currentParams.get(i);
				Expression oldParam = (Expression) current;
				
				if (i == paramPlace) {
					if (isValidNumber(param.toString())) {
						NumberLiteral newParam = ast.newNumberLiteral();
						
						newParam.setToken(param.toString());				
						
						rewrite.replace(oldParam, newParam, null);
											
					} else if (param.toString().startsWith("-"))	{
						PrefixExpression newParam = ast.newPrefixExpression();
						
						newParam.setOperator(Operator.MINUS);
						
						if (isValidNumber(oldParam.toString())) {
							NumberLiteral num = ast.newNumberLiteral();
							String paramWithSign = param.toString();
							String paramWOSign = paramWithSign.substring(1, paramWithSign.length());
							
							num.setToken(paramWOSign);
							
							newParam.setOperand(num);
							
							rewrite.replace(oldParam, newParam, null);
						}
						
					} else if (param.toString().startsWith("(") && param.toString().endsWith(")")) {
						ParenthesizedExpression newParam = ast.newParenthesizedExpression();
						
						if (isValidNumber(oldParam.toString())) {
							NumberLiteral num = ast.newNumberLiteral();
							String paramWithParens = param.toString();
							String paramWOParens = paramWithParens.substring(1,paramWithParens.length()-1);
							
							num.setToken(paramWOParens);
							
							rewrite.replace(oldParam, newParam, null);
						}
					} else if (current instanceof BooleanLiteral) {
						
					} else if (current instanceof StringLiteral) {
						StringLiteral newParam = ast.newStringLiteral();
						
						newParam.setLiteralValue(param.toString());
						
						rewrite.replace(oldParam, newParam, null);
						
					} else if (current instanceof CharacterLiteral && param.toString().length()==1) {
						CharacterLiteral newParam = ast.newCharacterLiteral();
						
						char newChar = param.toString().charAt(0);
						newParam.setCharValue(newChar);
						
						rewrite.replace(oldParam, newParam, null);
						
					}
				}
			}
			
		} else {
			// handle each primitive type / simple expression accordingly
			Expression oldParam = (Expression) currentParam;
			
			if (isValidNumber(param.toString())) {
				NumberLiteral newParam = ast.newNumberLiteral();
				
				newParam.setToken(param.toString());				
				
				rewrite.replace(oldParam, newParam, null);
				
			} else if (param.toString().startsWith("-")) {
				PrefixExpression newParam = ast.newPrefixExpression();
				
				newParam.setOperator(Operator.MINUS);
				
				if (isValidNumber(oldParam.toString())) {
					NumberLiteral num = ast.newNumberLiteral();
					String paramWithSign = param.toString();
					String paramWOSign = paramWithSign.substring(1, paramWithSign.length());
					
					num.setToken(paramWOSign);
					
					newParam.setOperand(num);
					
					rewrite.replace(oldParam, newParam, null);
				}
				
			} else if (param.toString().startsWith("(") && param.toString().endsWith(")")) {
				ParenthesizedExpression newParam = ast.newParenthesizedExpression();
				
				if (isValidNumber(oldParam.toString())) {
					NumberLiteral num = ast.newNumberLiteral();
					String paramWithParens = param.toString();
					String paramWOParens = paramWithParens.substring(1,paramWithParens.length()-1);
					
					num.setToken(paramWOParens);
					
					rewrite.replace(oldParam, newParam, null);
				}
				
			} else if (currentParam instanceof StringLiteral){
				StringLiteral newParam = ast.newStringLiteral();

				newParam.setLiteralValue(param.toString());								
				
				rewrite.replace(oldParam, newParam, null);	
			} else if (currentParam instanceof BooleanLiteral) {
				BooleanLiteral newParam;
				
				if ((boolean) currentParam) {
					newParam = ast.newBooleanLiteral(false);
				} else {
					newParam = ast.newBooleanLiteral(true);
				}
				
			} else if (currentParam instanceof CharacterLiteral && param.toString().length() == 1) {
				CharacterLiteral newParam = ast.newCharacterLiteral();
				
				newParam.setCharValue((char)param);
				
				rewrite.replace(oldParam, newParam, null);
			}
			
		}

		
		TextEdit edits = rewrite.rewriteAST(testDocument, JavaCore.getOptions());
		edits.apply(testDocument);
		
		newSource = testDocument.get();
		icu.getBuffer().setContents(newSource);
		
		return newSource;
	}
	
	private void runTests(IWorkbenchPage page, File executorDirectory, Object newParam, int lineNo)
			throws BadLocationException, JavaModelException, InterruptedException, ExecuteException, IOException {
		
		// update and save page
//		updateTestInput(newParam);
		savePage(page);
		
		// wait for build to finish before running test
		TimeUnit.SECONDS.sleep(2);
		
		// update AST parser
//		updateASTParser();
		getMethodParameters(testDocument.get(), targetTest.getTargetMethod(), targetTest.getTestMethod(), false, lineNo);
				
		// D4J compile
		d4jCompile(executorDirectory); 
		
		// D4J test
		d4jTest(executorDirectory);
				
	}
	
	private boolean isValidNumber(String input) {
		try {
			Integer newNumber = Integer.parseInt(input.toString());
			System.out.println(input + " is an integer.");
			
			return true;
			
		} catch (NumberFormatException e) {
			 System.out.println(input + " is not an integer!");
		}
		
		try {
			Double newNumber = Double.parseDouble(input);
			System.out.println(input + " is a double.");
			
			return true;
			
		} catch (NumberFormatException e) {
			System.out.println(input.toString() + " is not a double!");
			
			try {
				Float newNumber = Float.parseFloat(input);
				System.out.println(input + " is a float.");
				
				return true;
				
			} catch (NumberFormatException e1) {
				System.out.println(input + " is not a float!");
			}
		}
		
		try {
			Long newNumber = Long.parseLong(input);
			System.out.println(input + " is a long.");
			
			return true;
		} catch (NumberFormatException e) {
			System.out.println(input + " is not a long!");
		}
		
		try {
			BigInteger newNumber = new BigInteger(input);
			System.out.println(input + " is a Big Integer.");
			
			return true;
			
		} catch (NumberFormatException e) {
			System.out.println(input + " is not a Big Integer!");
		}
		
		try {
			BigDecimal newNumber = new BigDecimal(input);	
			System.out.println(input + " is a Big Decimal.");
			
			return true;
			
		} catch (NumberFormatException e) {
			System.out.println(input + " is not a Big Decimal!");
		}
		
		
		return false;
	}

	private void parseGeneratedTests(String targetMethod, File[] testFiles) throws FileNotFoundException, IOException {
		
		if (testFiles != null) {
			for (File file : testFiles) {
				// ignore scaffolding file
				if (!file.getName().contains("scaffolding")) {						
//						System.out.println("Generated test file --> " + file.getName());
					
					// find generated inputs closest to each original 					
					List<Object> generatedInputs = findGeneratedInputs(targetMethod, file);					
					List<String> originals = targetTest.getOriginalParameters();
					String original = targetTest.getOriginalParameter();
					
					int distance = 0;
					Object oldNumValue;
					Object newNumValue;
									
					for (int j=0; j < generatedInputs.size(); j++) {
						
						// check if multi or single parameter
						Object singleGenerated = generatedInputs.get(j);
						if (singleGenerated instanceof ArrayList) {
							// multi-param
							List<Object> genParams = (ArrayList<Object>)singleGenerated;
							
							// iterate over lists to find compare inputs in each position (assumption = same number of params and same order)
							if (originals.size() == genParams.size()) {
								
 								for (int i=0; i < originals.size(); i++) {

									String[] oldAndNew = new String[2];
									
									String originalParam = originals.get(i); 
									Object generatedParam = genParams.get(i);
									
									if (generatedParam instanceof NumberLiteral) { 
										NumberLiteral newNum = (NumberLiteral) generatedParam;
										
										Object oldNumType = determineNumType(originalParam);
										Object newNumType = determineNumType(newNum.toString());
										
										distance = getDistance(originalParam, oldNumType, newNumType);
										
										oldAndNew[0] = originalParam;
										oldAndNew[1] = newNum.toString();
										
										editDistances.put(oldAndNew, distance);
										
										System.out.println("Success! Distance between original and generated input = " + distance);
										
									} else if (generatedParam instanceof CastExpression) {
										CastExpression fullGenerated = (CastExpression) generatedParam;
										Type paramType = fullGenerated.getType();
										Expression paramValue = fullGenerated.getExpression();
										
										Object oldNumType = determineNumType(originalParam);
										Object newNumType = determineNumType(paramValue.toString());
										
										distance = getDistance(originalParam, oldNumType, newNumType);
										
										oldAndNew[0] = originalParam;
										oldAndNew[1] = fullGenerated.toString();
										
										editDistances.put(oldAndNew, distance);			
										
										System.out.println("Success! Distance between original and generated input = " + distance);
										
									} else if (generatedParam instanceof PrefixExpression) {
										PrefixExpression fullGenerated = (PrefixExpression) generatedParam;
										
										System.out.println(fullGenerated.getOperator());
										System.out.println(fullGenerated.getOperand());
										
										Object oldNumType = determineNumType(originalParam);
										Object newNumType = determineNumType(fullGenerated.toString());
										
										distance = getDistance(originalParam, oldNumType, newNumType.toString());
										
										oldAndNew[0] = originalParam;
										oldAndNew[1] = fullGenerated.toString();
										
										editDistances.put(oldAndNew, distance);
										
										System.out.println("Success! Distance between original and generated input = " + distance);
										
									} else if (generatedParam instanceof ParenthesizedExpression) {
										ParenthesizedExpression fullGenerated = (ParenthesizedExpression) generatedParam;
										Expression genValue = fullGenerated.getExpression();
										
										Object oldNumType = determineNumType(originalParam);
										Object newNumType = determineNumType(genValue.toString());
										
										distance = getDistance(originalParam, oldNumType, newNumType);
										
										oldAndNew[0] = originalParam;
										oldAndNew[1] = fullGenerated.toString();
										
										editDistances.put(oldAndNew, distance);
										
										System.out.println("Success! Distance between original and generated input = " + distance);
																				
									} else if (generatedParam instanceof StringLiteral || generatedParam instanceof CharacterLiteral) {
										
										String genInput = String.valueOf(singleGenerated);
										
										if (originalParam.length() < genInput.length()) {
											distance = hammingDistance(originalParam, genInput);
										} else {
											distance = hammingDistance(genInput, originalParam);
										}
										
										oldAndNew[0] = originalParam;
										oldAndNew[1] = genInput;
										
										editDistances.put(oldAndNew, distance);
										
										System.out.println("Success! Distance between original and generated input = " + distance);
									} else if (generatedParam instanceof SimpleName) {
										// TODO what to do if simple name? am I storing what I need from ASTVisitor?
									}
								}
							}
							
						} else {
							
							System.out.println("Generated input = " + singleGenerated.toString());	
														
							String[] oldAndNew = new String[2];
							
							// Strings (Hamming distance)
							if (singleGenerated instanceof StringLiteral || singleGenerated instanceof CharacterLiteral) {
								String genInput = String.valueOf(singleGenerated);
								
								if (genInput.startsWith("\"")) {
									genInput = genInput.substring(1, genInput.length()-1);
								}
								
								System.out.println(original);
								System.out.println(genInput);
								
								if (original.length() < genInput.length()) {
									distance = hammingDistance(original, genInput);
								} else {
									distance = hammingDistance(genInput, original);
								}
								
								oldAndNew[0] = original;
								oldAndNew[1] = genInput;
								
								if (!genInput.equals("\"\"")) {
									editDistances.put(oldAndNew, distance);								
								}
								
								System.out.println("Success! Distance between original and generated input = " + distance);
								
							} else if (singleGenerated instanceof NumberLiteral) {
								NumberLiteral newNum = (NumberLiteral) singleGenerated;
								
								Object oldNumType = determineNumType(original);
								Object newNumType = determineNumType(newNum.toString());
								
								distance = getDistance(original, oldNumType, newNumType);
								
								oldAndNew[0] = original;
								oldAndNew[1] = newNum.toString();
								
								editDistances.put(oldAndNew, distance);
								
								System.out.println("Success! Distance between original and generated input = " + distance);
								
							} else if (singleGenerated instanceof PrefixExpression) {
								PrefixExpression fullGenerated = (PrefixExpression) singleGenerated;
								
								System.out.println(fullGenerated.getOperator());
								System.out.println(fullGenerated.getOperand());
								
								Object oldNumType = determineNumType(original);
								Object newNumType = determineNumType(fullGenerated.toString());
								
								distance = getDistance(original, oldNumType, newNumType.toString());
								
								oldAndNew[0] = original;
								oldAndNew[1] = fullGenerated.toString();
								
								editDistances.put(oldAndNew, distance);
								
								System.out.println("Success! Distance between original and generated input = " + distance);
								
							} else if (singleGenerated instanceof CastExpression) {
								CastExpression fullGenerated = (CastExpression) singleGenerated;
								Type paramType = fullGenerated.getType();
								Expression paramValue = fullGenerated.getExpression();
								
								Object oldNumType = determineNumType(original);
								Object newNumType = determineNumType(paramValue.toString());
								
								distance = getDistance(original, oldNumType, newNumType);
								
								oldAndNew[0] = original;
								oldAndNew[1] = fullGenerated.toString();
								
								editDistances.put(oldAndNew, distance);			
								
								System.out.println("Success! Distance between original and generated input = " + distance);
								
							} else if (singleGenerated instanceof ParenthesizedExpression) {
								ParenthesizedExpression fullGenerated = (ParenthesizedExpression) singleGenerated;
								Expression genValue = fullGenerated.getExpression();
								
								Object oldNumType = determineNumType(original);
								Object newNumType = determineNumType(genValue .toString());
								
								distance = getDistance(original, oldNumType, newNumType);
								
								oldAndNew[0] = original;
								oldAndNew[1] = fullGenerated.toString();
								
								editDistances.put(oldAndNew, distance);
								
								System.out.println("Success! Distance between original and generated input = " + distance);
								
							}
							
						}	
					}
					
					System.out.println("Parsing of generated inputs successful!");
					
					// find closest input to original(s)
					closestGeneratedInputs = findClosestInputs(isMultiParam);
					
				}
				
					
			}
		}
	}

	private int getDistance(String original, Object oldNumType, Object newNumType) {
		int distance = 0;
		if (oldNumType != null && newNumType != null) {
			if (oldNumType instanceof Integer && newNumType instanceof Integer) {
				Integer oldVal = (Integer) oldNumType;
				Integer genVal = (Integer) newNumType;
				
				distance = Math.abs(oldVal - genVal);
			} else if (determineNumType(original) instanceof Double && newNumType instanceof Double) {
				Double oldVal = (Double) oldNumType;
				Double genVal = (Double) newNumType;
				
				distance = (int) Math.abs(oldVal-genVal);
			} else if (oldNumType instanceof Float && newNumType instanceof Float) {
				Float oldVal = (Float) oldNumType;
				Float genVal = (Float) newNumType;
				
				distance = (int) Math.abs(oldVal-genVal);
			} else if (oldNumType instanceof Long && newNumType instanceof Long) {
				Long oldVal = (Long) oldNumType;
				Long genVal = (Long) newNumType;
				
				distance = (int) Math.abs(oldVal-genVal);
			} else if (oldNumType instanceof BigInteger && newNumType instanceof BigInteger) {
				BigInteger oldVal = (BigInteger) oldNumType;
				BigInteger genVal = (BigInteger) newNumType;
				
				distance = (int) Math.abs(oldVal.floatValue()-genVal.floatValue());
			} else if (oldNumType instanceof BigDecimal && newNumType instanceof BigDecimal) {
				BigDecimal oldVal = (BigDecimal) oldNumType;
				BigDecimal genVal = (BigDecimal) newNumType;
				
				distance = (int) Math.abs(oldVal.floatValue() - genVal.floatValue());
			}
		}
		
		return distance;
	}

	private Object determineNumType(String newNum) {
		try {
			Integer newNumber = Integer.parseInt(newNum.toString());
			System.out.println(newNum + " is an integer.");
			
			return newNumber;
			
		} catch (NumberFormatException e) {
			 System.out.println(newNum + " is not an integer!");
		}
		
		try {
			Double newNumber = Double.parseDouble(newNum);
			System.out.println(newNum + " is a double.");
			
			return newNumber;
			
		} catch (NumberFormatException e) {
			System.out.println(newNum.toString() + " is not a double!");
			
			try {
				Float newNumber = Float.parseFloat(newNum);
				System.out.println(newNum + " is a float.");
				
				return newNumber;
				
			} catch (NumberFormatException e1) {
				System.out.println(newNum + " is not a float!");
			}
		}
		
		try {
			Long newNumber = Long.parseLong(newNum);
			System.out.println(newNum + " is a long.");
			
			return newNumber;
		} catch (NumberFormatException e) {
			System.out.println(newNum + " is not a long!");
		}
		
		try {
			BigInteger newNumber = new BigInteger(newNum);
			System.out.println(newNum + " is a Big Integer.");
			
			return newNumber;
			
		} catch (NumberFormatException e) {
			System.out.println(newNum + " is not a Big Integer!");
		}
		
		try {
			BigDecimal newNumber = new BigDecimal(newNum);	
			System.out.println(newNum + " is a Big Decimal.");
			
			return newNumber;
			
		} catch (NumberFormatException e) {
			System.out.println(newNum + " is not a Big Decimal!");
		}
		
		return null;
	}

	private void runEvoSuite(File executorDirectory, String targetClassPackage, String classDir)
			throws ExecuteException, IOException {
		DefaultExecutor evoExecutor = new DefaultExecutor();
		evoExecutor.setWorkingDirectory(executorDirectory);

		CommandLine runEvoSuiteCmd = new CommandLine("java");
		runEvoSuiteCmd.addArgument("-jar");
		runEvoSuiteCmd.addArgument(testGenJar);
		runEvoSuiteCmd.addArgument("-class");
		runEvoSuiteCmd.addArgument(targetClassPackage);
		runEvoSuiteCmd.addArgument("-projectCP");
		runEvoSuiteCmd.addArgument(classDir);
			runEvoSuiteCmd.addArgument("-criterion");
			runEvoSuiteCmd.addArgument("branch");
					
		evoExecutor.execute(runEvoSuiteCmd);
	}

	private List<Object> findGeneratedInputs(String targetMethod, File file) throws FileNotFoundException, IOException {
		InputStream is = new FileInputStream(file);
		BufferedReader br = new BufferedReader(new InputStreamReader(is));
		
		
		String line = br.readLine();
		StringBuilder sb = new StringBuilder();
		
		while (line != null) {
			sb.append(line).append("\n");
			line = br.readLine();
		}
		
		String fileAsString = sb.toString();
		Document genTestDocument = new Document(fileAsString);
		
		
//		
//		IFile genTestFile = (IFile) file;
//		IJavaElement element = JavaCore.create(genTestFile);
//		ICompilationUnit icu = (ICompilationUnit) element;
		
		// TODO Make sure this works!
		ASTParser genTestParser = createParser(genTestDocument.get());
		CompilationUnit gcu = (CompilationUnit) genTestParser.createAST(null);
		
		GeneratedTestVisitor visitor = new GeneratedTestVisitor(fileAsString.toCharArray(), targetMethod);
		gcu.accept(visitor);
		
		List<Object> generatedInputs = new ArrayList<>();
		
		// for single parameter tests
		if (!visitor.getIsMultiParam()) {
			generatedInputs = visitor.getGeneratedSingleParamInputs();			
		} else {
			generatedInputs = visitor.getGeneratedMultiParamInputs();
		}
		
		return generatedInputs;
	}
	
	private String findClosestInput(HashMap<String, Integer> editDistances) {
		String closestInput = "";
		int lowestDistance = 0;
		boolean firstIteration = true;
		
		Iterator it = editDistances.entrySet().iterator();
		while (it.hasNext()) {
			Map.Entry<String, Integer> pair = (Map.Entry<String, Integer>)it.next();
			int value = (int) pair.getValue();
			String key = pair.getKey().toString();
			
			System.out.println("Input = " + key + " with edit distance = " + value);
			
			if (firstIteration) {
				closestInput = key;
				lowestDistance = value;
				firstIteration = false;
			} else {
				if (value < lowestDistance) {
					closestInput = key;
					lowestDistance = value;
				}
			}
		}
		
		return closestInput;
	}

	private HashMap<String, List<String>> findClosestInputs (boolean isMultiParam) {
		// store closest inputs with input it's closest too (for multi param)
		HashMap<String, List<String>> closestInputs = new HashMap<String, List<String>>();
		int lowestDistance = 0;
		boolean firstIteration = true;

		
		if (isMultiParam) {
			List<String> originals = targetTest.getOriginalParameters();
			
			for (String s: originals) {
				Iterator it = editDistances.entrySet().iterator();
				// reset first iteration to true for each original parameter
				firstIteration = true;
				
				while (it.hasNext()) {
					Map.Entry<String[], Integer> pair = (Map.Entry<String[],Integer>) it.next();
					int distanceValue = (int) pair.getValue();
					String[] origAndGen = pair.getKey();
					
					if (s.equals(origAndGen[0])) {
						if (firstIteration && distanceValue > 0) {
							lowestDistance = distanceValue;
							List<String> inputsList = new ArrayList<>();
							// add to closest inputs if edit distance between 1 and 3
							if (lowestDistance > 0 && lowestDistance <=3) {
								inputsList.add(origAndGen[1]);
								closestInputs.put(s, inputsList);
							} else {
								closestInputs.put(s, inputsList);
							}
							firstIteration = false;
						} else {
							if ((distanceValue <= lowestDistance && distanceValue > 0) || (distanceValue > 0 && distanceValue <= 3)) {
								lowestDistance = distanceValue;
								List<String> closest = closestInputs.get(s);
								closest.add(origAndGen[1]);
								closestInputs.put(s, closest);
							}
						}
					}
				}
			}
			
		} else {
			Iterator it = editDistances.entrySet().iterator();
			String original = targetTest.getOriginalParameter();
			
			while(it.hasNext()) {
				Map.Entry<String[], Integer> pair = (Map.Entry<String[],Integer>) it.next();
				int distanceValue = (int) pair.getValue();
				String[] origAndGen = pair.getKey();
				
				if (firstIteration) {
					lowestDistance = distanceValue;
					List<String> inputsList = new ArrayList<>();
					
					// add to closest inputs if edit distance between 1 and 3
					if (lowestDistance > 0 && lowestDistance <=3) {
						inputsList.add(origAndGen[1]);
						closestInputs.put(original, inputsList);
					} else {
						closestInputs.put(original, inputsList);
					}
					firstIteration = false;
				} else {
					if (distanceValue <= lowestDistance && distanceValue > 0) {
						lowestDistance = distanceValue;
						List<String> closest = closestInputs.get(original);
						closest.add(origAndGen[1]);
						closestInputs.put(original, closest);
					}
				}
				
			}
			
		}
		
		return closestInputs;
	}

	private void removeQuotations(HashMap<String, String> closestInputs) {
		for (int i=0; i<closestInputs.size(); i++) {
			String s = closestInputs.get(i);
			closestInputs.remove(i);
//			closestInputs.add(i, s.substring(1, s.length()-1));
			System.out.println(closestInputs.get(i));
			
		}
	}
	
	private static int hammingDistance(String s1, String s2) {
		int i = 0, count = 0;
		
		while (i < s1.length()) {
			if (s1.charAt(i) != s2.charAt(i))
				count++;
			i++;
		}
		return count;	
	}
	
	private int levenshteinDistance(String originalString, String generatedString) {
		LevenshteinDetailedDistance distanceStrategy = new LevenshteinDetailedDistance();
		
		LevenshteinResults result = distanceStrategy.apply(originalString, generatedString);
		
		return result.getDistance();
	}
	
	
	private void writeOutputFile() {
 		BufferedWriter bwPassing = null;
		BufferedWriter bwFailing = null;		
		
		FileWriter fwPassing = null;
		FileWriter fwFailing = null;
		
//		String passingOutputFilename = workingDirectory.getPath()+"/holmes-output-passing.txt";
//		String failingOutputFilename = workingDirectory.getPath()+"/holmes-output-failing.txt";
		
		String passingOutputFilename = workingDirectory.getAbsolutePath() + "/holmes-output-passing.txt";
		String failingOutputFilename = workingDirectory.getAbsolutePath() + "/holmes-output-failing.txt";
		
		try {
			fwPassing = new FileWriter(passingOutputFilename);
			fwFailing = new FileWriter(failingOutputFilename);
			
			bwPassing = new BufferedWriter(fwPassing);
			bwFailing = new BufferedWriter(fwFailing);
			
			List<Object> used = new ArrayList<Object>();
			
			for (String test : passingTests) {
			
				for (Object input : executedInputs) {
					writeTest(bwPassing, used, test, input);
				}
			}
			
			for (String test : failingTests) {
				for (Object input : executedInputs) {
					writeTest(bwFailing, used, test, input);
				}
			}
			
			
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			try {
				if (bwPassing != null)
					bwPassing.close();
				
				if (bwFailing != null)
					bwFailing.close();

				if (fwPassing != null)
					fwPassing.close();
				
				if (fwFailing != null) {
					fwFailing.close();
				}

			} catch (IOException ex) {
				ex.printStackTrace();
			}
		}
		
	}

	private void writeTest(BufferedWriter bwPassing, List<Object> used, String test, Object input) throws IOException {
		String subTest = test.substring(test.lastIndexOf(targetTest.getTargetMethod()));
		String testInput = input.toString();
		String params = subTest.substring(subTest.lastIndexOf("("));
		
		// find executed input that matches current passing test
		if (params.contains(testInput) && used.contains(subTest) == false && used.contains(input) == false) {
			used.add(subTest);
			used.add(input);
			
			// bold testInput within params
			String formattedParams = params.substring(0, params.indexOf(testInput)) + "<b>" 
					+ params.substring(params.indexOf(testInput), params.indexOf(testInput)+testInput.length()) + "</b>" 
					+ params.substring(params.indexOf(testInput)+testInput.length(), params.length());
			
			System.out.println(formattedParams);
			
			// re-construct test
			String formattedTest = test.substring(0, test.indexOf(params)) + formattedParams;
			
			System.out.println(formattedTest);
			
			bwPassing.write("P:" + formattedTest);
			bwPassing.write("\n");
		}
	}
	
	
	
	private void savePage(IWorkbenchPage page) {
		
		for (IEditorPart dirtyPage: page.getDirtyEditors()) {
			dirtyPage.doSave(null);
			System.out.println("Editor saved!");
		}

	}
	
	private String replaceVariableDeclaration(ASTRewrite rewrite, Object newParam, String type)
			throws BadLocationException, JavaModelException {

		// Old variable fragments
		VariableDeclarationStatement oldVarDec = (VariableDeclarationStatement) currentParam;
		VariableDeclarationFragment frag = (VariableDeclarationFragment) oldVarDec.fragments().get(0);
		SimpleName varName = frag.getName();
		
		// new variable fragments
		String newSource = "";
		VariableDeclarationFragment newVarFrag = ast.newVariableDeclarationFragment();
		SimpleName newVarName = ast.newSimpleName(varName.getIdentifier());
		newVarFrag.setName(newVarName);
		
		targetTest.setNewParameter(newParam.toString());

		// new variable declaration statement based on fragment
		// TODO: is this in the wrong location?
		VariableDeclarationStatement newVarDec = ast.newVariableDeclarationStatement(newVarFrag);
		
		// determine which type of parameter passed in
		if (newParam instanceof BooleanLiteral) {
			// already has value if boolean
			BooleanLiteral param = (BooleanLiteral)newParam;
			newVarFrag.setInitializer(param);			
			
			newVarDec.setType(ast.newSimpleType(ast.newSimpleName("boolean")));
			
		} else if (newParam instanceof StringLiteral) {
			StringLiteral param = (StringLiteral)newParam;
			if (this.input == null) {
				// TODO should this be actual null value or the string "null"?
				param.setLiteralValue("null");
				
			} else {
				param.setLiteralValue(this.input.toString());				
			}
			
			newVarFrag.setInitializer(param);
			newVarDec.setType(ast.newSimpleType(ast.newSimpleName("String")));
			
		} else if (newParam instanceof CharacterLiteral) {
			CharacterLiteral param = (CharacterLiteral)newParam;
			if (this.input == null) {
				// TODO: figure out how to do this (if possible)
			} else {
				param.setCharValue((char)this.input);				
			}
			
			newVarFrag.setInitializer(param);
			newVarDec.setType(ast.newSimpleType(ast.newSimpleName("char")));
			
		} else if (newParam instanceof NumberLiteral) {
			
			if (this.input == null) {
				// TODO handle if null
			} else {
				NumberLiteral param = (NumberLiteral)newParam;
				
				if (this.input == null) {
					// TODO handle if null
				} else {
					param.setToken(this.input.toString());					
				}
				
				newVarFrag.setInitializer(param);
				
				if (type.equals("int")) {
					newVarDec.setType(ast.newSimpleType(ast.newSimpleName("int")));
					
				} else if (type.equals("float")) {
					newVarDec.setType(ast.newSimpleType(ast.newSimpleName("float")));
					
				} else if (type.equals("double")) {
					newVarDec.setType(ast.newSimpleType(ast.newSimpleName("double")));
					
				} else if (type.equals("short")) {
					newVarDec.setType(ast.newSimpleType(ast.newSimpleName("short")));
					
				} else if (type.equals("long")) {
					newVarDec.setType(ast.newSimpleType(ast.newSimpleName("long")));
					
				}
				
			}
			
		}
		
		rewrite.replace(oldVarDec, newVarDec, null);
		
		TextEdit edits = rewrite.rewriteAST(testDocument, JavaCore.getOptions());
		edits.apply(testDocument);
		
		newSource = testDocument.get();
		icu.getBuffer().setContents(newSource);
		
		return newSource;
	}
	
	
	private void d4jCompile(File executorDirectory) throws ExecuteException, IOException {
		CommandLine d4j_compile_cmdLine = new CommandLine("/Users/bjohnson/Documents/Research_2017-2018/defects4j/framework/bin/defects4j");
		d4j_compile_cmdLine.addArgument("compile");
		
		DefaultExecutor d4j_compile_executor = new DefaultExecutor();		
		d4j_compile_executor.setWorkingDirectory(executorDirectory);
		
		System.out.println(d4j_compile_cmdLine.toString());
		
		try {
			d4j_compile_executor.execute(d4j_compile_cmdLine);
			
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	
	private void d4jTest(File executorDirectory) throws ExecuteException, IOException {
		// Store output to know if test passed or failed
		ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
		PumpStreamHandler streamHandler = new PumpStreamHandler(outputStream);
		
		CommandLine d4j_test_cmdLine = new CommandLine("/Users/bjohnson/Documents/Research_2017-2018/defects4j/framework/bin/defects4j");
		d4j_test_cmdLine.addArgument("test");
		d4j_test_cmdLine.addArgument("-t");
		
		// get package name
		String path = testFile.getFullPath().toString();
		String fullPackage = path.replaceAll("\\/", ".");
		String targetPackage = fullPackage.substring(fullPackage.indexOf("org"), fullPackage.length()-5);
		String singleTest = targetPackage + "::" + targetTest.getTestMethod();
		
		d4j_test_cmdLine.addArgument(singleTest); 		
		
		DefaultExecutor d4j_test_executor = new DefaultExecutor();		
		d4j_test_executor.setWorkingDirectory(executorDirectory);	
		d4j_test_executor.setStreamHandler(streamHandler);
		
		System.out.println(d4j_test_cmdLine.toString());
		
		try {
			d4j_test_executor.execute(d4j_test_cmdLine);
			
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		System.out.println(outputStream.toString());
		
		// Store test in appropriate list
		if (outputStream.toString().contains("Failing tests: 1") && failingTests.size() < 3) {
		
			failingTests.add(targetTest.getFullTest());				

		} else {
//			System.out.println(targetTest.getFullTest());
			
			passingTests.add(targetTest.getFullTest());				
			
		}
	
	}	

	
	private void writeOriginalTestToFile(String filename) {
		BufferedWriter bw = null;
		FileWriter fw = null;
		
		try {
			fw = new FileWriter(filename);
			bw = new BufferedWriter(fw);
			
			bw.write("O: " + targetTest.getOriginalTest());
			bw.write("\n");
			
			
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			try {
				if (bw != null)
					bw.close();

				if (fw != null)
					fw.close();

			} catch (IOException ex) {
				ex.printStackTrace();
			}
		}
		
	}
	

	private void runFuzzers(String cmdLineArg, boolean originalInput, String fileID) throws ExecuteException, IOException {
		DefaultExecutor py_executor = new DefaultExecutor();
		py_executor.setWorkingDirectory(new File(workingDirectory.getPath() + "/fuzzers/"));

		CommandLine py_fuzzer = new CommandLine("./fuzz.sh");
//		py_lower_cmdLine.addArgument("fuzz-lowercase.py");
		py_fuzzer.addArgument(cmdLineArg);
//		py_lower_cmdLine.addArgument(">");
		
		// pipe output to files for parsing
		if (originalInput) {
			py_fuzzer.addArgument("fuzzer_results_original_" + fileID + ".txt");
		} else {
			py_fuzzer.addArgument("fuzzer_results_generated_" + fileID +".txt");
		}

		py_executor.execute(py_fuzzer);
		System.out.println("Success!");
	}
	
	private void parseOtherMutations() throws FileNotFoundException, IOException {
		File otherMutationsFile = new File("other-mutations.txt");
		FileReader otherFileReader = new FileReader(otherMutationsFile);
		BufferedReader otherBR = new BufferedReader(otherFileReader);
		
		String otherLine;
		
		while ((otherLine = otherBR.readLine()) != null) {
			if (otherLine.startsWith("\"") && otherLine.endsWith("\"")) {
				String removeQuotes = otherLine.replace("\"", "");
				String removeSemicolon = removeQuotes.substring(0, removeQuotes.length()-1);
				
				System.out.println(removeSemicolon);
				
				fuzzedValues.add(removeSemicolon);
			} else {
				
				fuzzedValues.add(otherLine);				
			}
		}
		
		otherBR.close();
	}

	private void parseLengthMutations() throws FileNotFoundException, IOException {
		File lengthMutationFile = new File("length-mutations.txt");
		FileReader lengthFileReader = new FileReader(lengthMutationFile);
		BufferedReader lengthBR = new BufferedReader(lengthFileReader);
		
		String lengthLine;
		
		while ((lengthLine = lengthBR.readLine()) != null	) {
			if (lengthLine.startsWith("\"") && lengthLine.endsWith("\"")) {
				String removeQuotes = lengthLine.replace("\"", "");
				String removeSemicolon = removeQuotes.substring(0, removeQuotes.length()-1);
								
				System.out.println(removeSemicolon);
				
				fuzzedValues.add(removeSemicolon);
			} else {
				
				fuzzedValues.add(lengthLine);
			}
		}
		
		lengthFileReader.close();
	}

	private void parseCaseMutations() throws FileNotFoundException, IOException {
		File caseMutationFile = new File("case-mutations.txt");
		FileReader caseFileReader = new FileReader(caseMutationFile);
		BufferedReader caseBR = new BufferedReader(caseFileReader);
		
		String caseLine;
		
		while ((caseLine = caseBR.readLine()) != null) {
			if (caseLine.startsWith("\"") && caseLine.endsWith("\"") ) {
				String removeQuotes = caseLine.replace("\"", "");
				String removeSemicolon = removeQuotes.substring(0, removeQuotes.length()-1);
								
				System.out.println(removeSemicolon);
				
				fuzzedValues.add(removeSemicolon);
			} else {
				
				fuzzedValues.add(caseLine);
			}
		}
		
		caseFileReader.close();
	}
	
	private void getMethodParameters(String source, String targetMethod, String targetTestMethod, boolean first, int lineNo) {
		TestMethodVisitor visitor;
		if (first) {
			visitor = new TestMethodVisitor(source.toCharArray(), targetMethod, targetTestMethod, true, lineNo);
		} else {
			visitor = new TestMethodVisitor(source.toCharArray(), targetMethod, targetTestMethod, false, lineNo);
		}
		
		cu.accept(visitor);		
		
		targetTest.setOriginalTest(visitor.getOriginalTest());			
		
		MethodInvocation testMethodInvoc = visitor.getFullMethod();
		
		if (visitor.getTestStatements() == null) {			
			targetTest.setFullTest(visitor.getFullTest());
		} else {
			targetTest.setFullTest(visitor.getTestStatements());
		}
		
		targetTest.setTestMethod(visitor.getTargetTestMethod());
		
		// set up old and new parameters for modification
		if (!visitor.getIsMultiParam()) {
			if (visitor.getIsNotLiteral()) {
				// if not hard coded string, get var frag with value
				currentParam = visitor.getFragOfInterest();
				
			} else {
				currentParam = visitor.getParamOfInterest();
			}
			
			System.out.println("Current parameter = " + currentParam.toString());
			
			// set original test parameter (if first go around)
			if (first) {
				String originalParam = currentParam.toString();
				// if String, make sure quotes aren't saved along with input (only value)
				if (originalParam.contains("\"")) {
					// TODO: for fragments, may need to do -2 to account for semi-colon at the end
					originalParam = originalParam.substring(originalParam.indexOf("\"")+1, originalParam.length()-1);
				}
				
				targetTest.setOriginalParameter(originalParam);
			}
			
		} else {
			System.out.println("Current set of parameters are:");
			for (Object param : visitor.getParamsOfInterst()) {
				currentParams.add(param);
				System.out.println(param.toString());	
				// set original test parameters (if first go around)
				if (first) {
					String originalParam = param.toString();
					
					if (originalParam.contains("\"")){
						originalParam = originalParam.substring(originalParam.indexOf("\""), originalParam.length()-1);
					}
					
					targetTest.addOriginalParameter(originalParam);
				}
			}
		}		
	}
	
	private void updateASTParser() {
		parser = createParser(testDocument.get());
				
		cu = (CompilationUnit) parser.createAST(null);
		ast = cu.getAST();
		
		if (ast.hasBindingsRecovery()) {
			System.out.println("Binding activated.");
		}
	}
	
	private ASTParser createParser(String source) {
		ASTParser parser = ASTParser.newParser(AST.JLS8);
		parser.setResolveBindings(true);
		parser.setKind(ASTParser.K_COMPILATION_UNIT);

		parser.setBindingsRecovery(true);

		Map options = JavaCore.getOptions();
//		JavaCore.setComplianceOptions(JavaCore.VERSION_1_6, options);
		parser.setCompilerOptions(options); 
		
		parser.setStatementsRecovery(true);
		parser.setSource(source.toCharArray());
		
		return parser;
	}
	
	private ITextSelection getSelection(CompilationUnitEditor editor) {
	     ISelection selection = editor.getSelectionProvider()
	            .getSelection();
	     return (ITextSelection) selection;
	}

	private String getSelectedText(CompilationUnitEditor editor) {
	     return getSelection(editor).getText();
	}

	@Override
	public void selectionChanged(IAction arg0, ISelection arg1) {

	}

	@Override
	public void setActiveEditor(IAction arg0, IEditorPart arg1) {
		
	}

}
