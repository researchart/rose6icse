package org.holmes.plugin.views;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.concurrent.TimeUnit;

import org.eclipse.core.resources.IFile;
import org.eclipse.jface.viewers.ITableLabelProvider;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTError;
import org.eclipse.swt.browser.Browser;
import org.eclipse.swt.browser.LocationEvent;
import org.eclipse.swt.browser.LocationListener;
import org.eclipse.swt.browser.OpenWindowListener;
import org.eclipse.swt.browser.WindowEvent;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.ISharedImages;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.browser.IWebBrowser;
import org.eclipse.ui.browser.IWorkbenchBrowserSupport;
import org.eclipse.ui.part.ViewPart;

public class HolmesView extends ViewPart {
	Composite composite;
	
	Browser browser;
    String browserId;
    volatile boolean allowUrlChange;
    
    String workingDirectory = "/Users/bjohnson/Documents/Research_2019-2020/causal_testing/Holmes/";
    
	public static class ViewLabelProvider extends LabelProvider implements ITableLabelProvider {
		public String getColumnText(Object obj, int index) {
			return getText(obj);
		}
		public Image getColumnImage(Object obj, int index) {
			return getImage(obj);
		}
		public Image getImage(Object obj) {
			return PlatformUI.getWorkbench().getSharedImages().getImage(ISharedImages.IMG_OBJ_ELEMENT);
		}
	}
	
	public HolmesView() {
		
	}
	
	public void createPartControl(Composite parent) {
		composite = parent;
		
		updateView();
		
	}
	
	private void openBrowserInEditor(LocationEvent event) {
        URL url;
        try {
            url = new URL(event.location);
        } catch (MalformedURLException ignored) {
            return;
        }
        IWorkbenchBrowserSupport support = PlatformUI.getWorkbench().getBrowserSupport();
        try {
            IWebBrowser newBrowser = support.createBrowser(browserId);
            browserId = newBrowser.getId();
            newBrowser.openURL(url);
            return;
        } catch (PartInitException e) {
        		e.printStackTrace();
        }
    }
	
	public void updateView() {
		IEditorPart editor = PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage().getActiveEditor();
		String projectName=""; 
		
		if (editor != null) {
			// TODO: get project
			IEditorInput editorInput = editor.getEditorInput();
			IFile file = (IFile) editorInput.getAdapter(IFile.class);
			
		if (file != null) {
			projectName = file.getProject().getName();	
		}
				

		}
		
		StringBuffer html = new StringBuffer();
		
		html.append("<head>");
		html.append("<link rel =\"stylesheet\" ");
		html.append("href=\"https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.css\">");
		html.append("<link href=\"/css/livepreview-demo.css\" rel=\"stylesheet\" type=\"text/css\">");
		html.append("<script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js\"></script>");
		html.append("<script src=\"https://code.jquery.com/jquery-1.11.3.min.js\"></script>");
		html.append("<script src=\"https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.js\"></script>");
		html.append("<script type=\"text/javascript\" src=\"/js/jquery-live-preview.js\"></script>");
		html.append("</head>");
		
		html.append("<body style=\"background-color:white;\"><hr>");
	
		
		if (projectName.equals("Defect_0_Training")) {
			showOutput(html, new File(workingDirectory + "/holmes-output-original.txt"), new File(workingDirectory + "/holmes-output-passing.txt"), new File(workingDirectory + "/holmes-output-failing.txt"), true);
		} else {
			if (projectName.equals("Defect_1")) {
				showOutput(html, new File(workingDirectory + "/test_traces/Defect_1_original.txt"), new File(workingDirectory + "/test_traces/Defect_1_passing.txt"), 
						new File(workingDirectory + "/test_traces/Defect_1_failing.txt"), false);
			} else if (projectName.equals("Defect_2")) {
				showOutput(html, new File(workingDirectory + "/test_traces/Defect_2_original.txt"), new File(workingDirectory + "/test_traces/Defect_2_passing.txt"), 
						new File(workingDirectory + "/test_traces/Defect_2_failing.txt"), false);
			} else if (projectName.equals("Defect_3")) {
				showOutput(html, new File(workingDirectory + "/test_traces/Defect_3_original.txt"), new File(workingDirectory + "/test_traces/Defect_3_passing.txt"), 
						new File(workingDirectory + "/test_traces/Defect_3_failing.txt"), false);
			} else if (projectName.equals("Defect_4")) {
				showOutput(html, new File(workingDirectory + "/test_traces/Defect_4_original.txt"), new File(workingDirectory + "/test_traces/Defect_4_passing.txt"), 
						new File(workingDirectory + "/test_traces/Defect_4_failing.txt"), false);
			} else if ((projectName.equals("Defect_5"))) {
				showOutput(html, new File(workingDirectory + "/test_traces/Defect_5_original.txt"), new File(workingDirectory + "/test_traces/Defect_5_passing.txt"), 
						new File(workingDirectory + "test_traces/Defect_5_failing.txt"), false);
			} else if (projectName.equals("Defect_6")) {
				showOutput(html, new File(workingDirectory + "/test_traces/Defect_6_original.txt"), new File(workingDirectory + "/test_traces/Defect_6_passing.txt"), 
						new File(workingDirectory + "/test_traces/Defect_6_failing.txt"), false);
			}
		}
		 
	}
	
	public void showOutput(StringBuffer html, File original, File passing, File failing, boolean training) {
		
		if (original.exists()) {
			try {
				BufferedReader br = new BufferedReader(new FileReader(original));
				
				String line = null;
				StringBuilder sb = new StringBuilder();
				
				while ((line=br.readLine())!=null) {
					sb.append(line);
					sb.append("<br>");
				}
				
				String originalContents = sb.toString();
				
				String oTest = "";
				if (training) {
					oTest = originalContents.substring(originalContents.indexOf("O:")+2);
					
				} else {
					oTest = originalContents.substring(originalContents.indexOf("O:")+2, originalContents.indexOf("T:"));
				}
				
				
				html.append("<h2> Original Failing Test</h2>");
				html.append("<font face='Monaco' size='2'>"+oTest+"</font>");
				
				if (!training) {
					String oTrace = originalContents.substring(originalContents.indexOf("T:")+2);
					
					html.append("<button onclick=\"myFunction()\">See Execution Trace</button>");
					html.append("<div id=\"original\" style=\"display:none\">\n");
					html.append(oTrace);
					html.append("</div>");
				}
				
				html.append("<br>");
				
				html.append("<script>\n" + 
						"function myFunction() {\n" + 
						"    var x = document.getElementById(\"original\");\n" + 
						"    if (x.style.display === \"none\") {\n" + 
						"        x.style.display = \"block\";\n" + 
						"    } else {\n" + 
						"        x.style.display = \"none\";\n" + 
						"    }\n" + 
						"}\n" + 
						"</script>");
				
				
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
		}
		
		if (passing.length() == 0) {
			html.append("<font face='Monaco' size='2'>" + "No similar passing tests found." +"</font>");
		}
		
		if (passing.exists() && passing.length() > 0) {
			try {
				BufferedReader br = new BufferedReader(new FileReader(passing));
				
				String line = null;
				StringBuffer sb = new StringBuffer();
				
				while ((line=br.readLine()) != null) {
					sb.append(line);
					sb.append("<br>");
				}
				
				String passingTests = sb.toString();
				
				html.append("<h2>Passing Tests</h2>");
				
				if (training) {
					String[] lines = sb.toString().split("P:");
					
					for (String test: lines) {
						html.append("<font face='Monaco' size='2'>" +test+"</font>");
						html.append("<br>");
					}
				} else {
					int lastIndexPassing = 0;
					String findStr  = "P:";
					int count = 0;
					String test = "";
					String findStrT = "T:";
					int lastIndexTrace = 0;
					String trace = "";					
					
					
					while (lastIndexPassing != -1) {
						lastIndexPassing = passingTests.indexOf(findStr, lastIndexPassing);
						
						lastIndexTrace = passingTests.indexOf(findStrT, lastIndexTrace);
						
						
						
						if (lastIndexPassing != -1) {
							
							test = passingTests.substring(lastIndexPassing+2, lastIndexTrace);							
							
							html.append("<font face='Monaco' size='2'>" +test+"</font>");
							html.append("<br>");
							
							lastIndexPassing += findStr.length();
							
							int nextIndex = passingTests.indexOf(findStr, lastIndexPassing);
							
							// Process differently if only one passing test
							if (nextIndex == -1) {
								trace = passingTests.substring(lastIndexTrace+2, passingTests.length());
							} else {
								trace = passingTests.substring(lastIndexTrace+2, nextIndex);						
							}
							
							
							lastIndexTrace += findStrT.length();
							
							html.append("<button onclick=\"myFunction"+count+"()\">See Execution Trace</button>");
							html.append("<div id=\"myDIV"+ count +"\" style=\"display:none\">\n");
							html.append(trace);
							html.append("</div>");
							
							
							
							html.append("<br>");
							
							html.append("<script>\n" + 
									"function myFunction"+count+"() {\n" + 
									"    var x = document.getElementById(\"myDIV"+ count
									+ "\");\n" + 
									"    if (x.style.display === \"none\") {\n" + 
									"        x.style.display = \"block\";\n" + 
									"    } else {\n" + 
									"        x.style.display = \"none\";\n" + 
									"    }\n" + 
									"}\n" + 
									"</script>");
							
							count ++;
						}
					}
					
				}
				

			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		
		html.append("<h2>Additional Failing Tests</h2>");
		
		
		if (failing.length() == 0) {
			html.append("<font face='Monaco' size='2'>" + "No similar failing tests found." +"</font>");
		}
		
		if (failing.exists() && failing.length() > 0) {
			try {
				BufferedReader br = new BufferedReader(new FileReader(failing));
				
				String line = null;
				StringBuffer sb = new StringBuffer();
				
				while ((line=br.readLine()) != null) {
					sb.append(line);
					sb.append("<br>");
				}
				
				String failingTests = sb.toString();				
				
				if (training) {
					String[] lines = sb.toString().split("\\n");
					
					for (String test: lines) {
						test = test.substring(2, test.length()).trim();
						html.append("<font face='Monaco' size='2'>" +test+"</font>");
						html.append("<br>");
						
							
						
					}
					
				} else {
					int lastIndexFailing = 0;
					String findStr  = "F:";
					String findStrT = "T:";
					int lastIndexTrace = 0;
					String test = "";
					String trace = "";
					int count = 5;
					
					while (lastIndexFailing != -1) {
						lastIndexFailing = failingTests.indexOf(findStr, lastIndexFailing);
						lastIndexTrace = failingTests.indexOf(findStrT, lastIndexTrace);						
						
						
						if (lastIndexFailing != -1) {
							test = failingTests.substring(lastIndexFailing+2, lastIndexTrace);
							
							html.append("<font face='Monaco' size='2'>" +test+"</font>");
							html.append("<br>");
							
							lastIndexFailing += test.length();
							
							int nextIndex = failingTests.indexOf(findStr, lastIndexFailing);
							
							// Process differently if only one passing test
							if (nextIndex == -1) {
								trace = failingTests.substring(lastIndexTrace+2, failingTests.length());
							} else {
								trace = failingTests.substring(lastIndexTrace+2, nextIndex);						
							}							
							
							lastIndexTrace += findStrT.length();
							
							html.append("<button onclick=\"myFunction"+count+"()\">See Execution Trace</button>");
							html.append("<div id=\"myDIV"+ count +"\" style=\"display:none\">\n");
							html.append(trace);
							html.append("</div>");							
							
							
							html.append("<br>");
							
							html.append("<script>\n" + 
									"function myFunction"+count+"() {\n" + 
									"    var x = document.getElementById(\"myDIV" + count
									+ "\");\n" + 
									"    if (x.style.display === \"none\") {\n" + 
									"        x.style.display = \"block\";\n" + 
									"    } else {\n" + 
									"        x.style.display = \"none\";\n" + 
									"    }\n" + 
									"}\n" + 
									"</script>");
							
							count ++;
						}
					}
					
				}
				
			
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		GridData data = new GridData(GridData.FILL_BOTH);
		data.grabExcessHorizontalSpace = true;
		data.grabExcessVerticalSpace = true;
		try {
			browser = new Browser(composite, SWT.NO_BACKGROUND);
			browser.setLayoutData(data);
			browser.setBackground(composite.getBackground());
			browser.addOpenWindowListener(new OpenWindowListener() {
				
				@Override
				public void open(WindowEvent event) {
					event.required = true; // Cancel opening of new windows				
				}
			}); 
			
			browser.addLocationListener(new LocationListener() {
				
				@Override
				public void changing(LocationEvent event) {
					// fix for SWT code on Won32 platform: it uses "about:blank"
					// before
					// set any non-null url. We ignore this url
					if (allowUrlChange || "about:blank".equals(event.location)) {
						return;
					}
					// disallow changing of property view content
					event.doit = false;
					// for any external url clicked by user we should leave
					// property view
					openBrowserInEditor(event);
				}
				@Override
				public void changed(LocationEvent event) {
					// TODO Auto-generated method stub
					
				}
			}); 
			
		} catch (SWTError e) {
			System.out.println("Could not create org.eclipse.swt.widgets.Composite.Browser");
		}
		
		String onReady = "$(document).ready(function() {  \n $(\".livepreview\").livePreview(); \n});";
		boolean result = browser.execute(onReady);
		
		if (!result){
			System.out.println(onReady);
		}
		
		browser.setText(html.toString());

	}
	
	public Composite getParent() {
		return composite;
	}
	public void setFocus() {
	}
}
