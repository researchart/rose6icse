package cs.purdue.edu.propagate.util;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.input.SAXBuilder;

import cs.purdue.edu.model.JavaFile;

public class CodeCloneUtil {
	//public static ArrayList<ArrayList<ClonedClass>> result = new ArrayList<>();
	private static String nicadDir = 
			"C:\\Users\\shiyu\\AppData\\Local\\Packages\\"
			+ "CanonicalGroupLimited.Ubuntu16.04onWindows_79rhkp1fndgsc\\"
			+ "LocalState\\rootfs\\home\\sy\\NiCad-5.0\\";

	
	public static void main(String[] args) throws JDOMException, IOException {
		// TODO Auto-generated method stub
		ArrayList<ArrayList<ClonedMethod>> result = readXML(
				"apache_functions-abstract-clones\\"
				+ "apache_functions-abstract-clones-0.20-classes.xml");
		for (ArrayList<ClonedMethod> classes: result) {
			for (ClonedMethod cls: classes) {
				System.out.println(cls.getFile()+" "+cls.getClass()+" "+cls.getStartline()+""+cls.getEndline());
			}
			System.out.println();
		}
	}
	
	public static ArrayList<ArrayList<ClonedMethod>> readXML(String filepath) throws JDOMException, IOException {
		File fin = new File(nicadDir + "systems\\" + filepath);
		ArrayList<ArrayList<ClonedMethod>> ret = new ArrayList<>();
		SAXBuilder saxBuilder = new SAXBuilder();
		Document document = saxBuilder.build(fin);
		Element  clone = document.getRootElement();
		//System.out.println("Root: " + clone);

		List<Element> classList = clone.getChildren();
		for (Element cls: classList) {
			//System.out.println(cls);
			ArrayList<ClonedMethod> methods = new ArrayList<>();
			for (Element src: cls.getChildren()) {
				methods.add(new ClonedMethod(
						src.getAttribute("file").getValue(),
						src.getAttribute("startline").getIntValue(),
						src.getAttribute("endline").getIntValue(),
						src.getAttribute("pcid").getIntValue()));
			}
			ret.add(methods);
		}
		return ret;
	}
}
