import javax.swing.text.html.parser.TagElement;

import org.eclipse.jdt.core.dom.Javadoc;

public class JavadocAnalyser {
	static Javadoc cmt;
	JavadocAnalyser(Javadoc doc) {
		cmt = doc; 
	}
	
	public static void Analysis() {
		for (Object o: cmt.tags()) {
			TagElement element = (TagElement) o;
			if (element.)
		}
		
	}
	
	
}
