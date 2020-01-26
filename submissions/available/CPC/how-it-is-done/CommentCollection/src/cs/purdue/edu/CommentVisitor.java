package cs.purdue.edu;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.eclipse.jdt.core.dom.ASTNode;
import org.eclipse.jdt.core.dom.ASTVisitor;
import org.eclipse.jdt.core.dom.BlockComment;
import org.eclipse.jdt.core.dom.BodyDeclaration;
import org.eclipse.jdt.core.dom.CompilationUnit;
import org.eclipse.jdt.core.dom.FieldDeclaration;
import org.eclipse.jdt.core.dom.IDocElement;
import org.eclipse.jdt.core.dom.IMethodBinding;
import org.eclipse.jdt.core.dom.IPackageBinding;
import org.eclipse.jdt.core.dom.ITypeBinding;
import org.eclipse.jdt.core.dom.IVariableBinding;
import org.eclipse.jdt.core.dom.Javadoc;
import org.eclipse.jdt.core.dom.LineComment;
import org.eclipse.jdt.core.dom.MemberRef;
import org.eclipse.jdt.core.dom.MethodDeclaration;
import org.eclipse.jdt.core.dom.MethodRef;
import org.eclipse.jdt.core.dom.Name;
import org.eclipse.jdt.core.dom.PackageDeclaration;
import org.eclipse.jdt.core.dom.SimpleName;
import org.eclipse.jdt.core.dom.SingleVariableDeclaration;
import org.eclipse.jdt.core.dom.Statement;
import org.eclipse.jdt.core.dom.TagElement;
import org.eclipse.jdt.core.dom.TextElement;
import org.eclipse.jdt.core.dom.Type;
import org.eclipse.jdt.core.dom.TypeDeclaration;
import org.eclipse.jdt.core.dom.VariableDeclaration;
import org.eclipse.jdt.core.dom.VariableDeclarationFragment;
import org.eclipse.jdt.core.dom.VariableDeclarationStatement;

import cs.purdue.edu.model.CodeEntity;
import cs.purdue.edu.model.Comment;
import cs.purdue.edu.model.Field;
import cs.purdue.edu.model.Parameter;
import cs.purdue.edu.model.Subject;
import cs.purdue.edu.model.Method;
import cs.purdue.edu.model.Variable;
import cs.purdue.edu.parser.CommentParser;
import cs.purdue.edu.model.Category;
import cs.purdue.edu.model.Class;

//comment visitor
class CommentVisitor extends ASTVisitor {
	// static List<MyLineComment> lineCommentList;
	// static List<MyBlockComment> blockCommentList;
	
	private final String source;
	private final String pack;
	private CodeLists codeLists = null;
	

	public CommentVisitor(String src, String pck, CodeLists lists) {
		super();
		source = src;
		pack = pck;
		codeLists = lists;
	}

	/*
	public boolean visit(PackageDeclaration node) {
		IPackageBinding binding = node.resolveBinding();
	}
	*/
	
	public boolean visit(TypeDeclaration node) {
		ITypeBinding binding = node.resolveBinding();
		if (binding == null) return true;
		Class cls = new Class();
		cls.setId(binding.getName());
		cls.setLineNumBegin(positionToLineNumber(node.getStartPosition()));
		cls.setLineNumEnd(positionToLineNumber(
				node.getStartPosition() + node.getLength() - 1));
		cls.setPack(pack);
		
		Javadoc doc = node.getJavadoc();
		if (doc != null) {
			cls.setComments(JavadocToCmt(
					doc, cls.getId(), Subject.subject.cls));
		}
		codeLists.classes.add(cls);
		return true;
		
	}
	
	public boolean visit(MethodDeclaration node) {
		IMethodBinding binding = node.resolveBinding();
		if (binding == null) return true;
		Method method = new Method();
		method.setId(binding.getName());
		method.setLineNumBegin(positionToLineNumber(node.getStartPosition()));
		method.setLineNumEnd(positionToLineNumber(
				node.getStartPosition() + node.getLength() - 1));
		method.setPack(pack);
		method.setRetType(binding.getReturnType().getName());
		
		Javadoc doc = node.getJavadoc();
		if (doc != null) {
			method.setComments(
					JavadocToCmt(doc, 
					method.getId(), 
					Subject.subject.method));
			/*for (Comment cmt: JavadocToCmt(doc, 
					method.getId(), 
					Subject.subject.method)) {
				//System.out.println("cmt-"+cmt.getOrigText());
			}*/
		}
		
		Class cls = currClass(method.getLineNumBegin(), method.getLineNumEnd());
		cls.addMethod(method);
		method.setClass(cls);
		codeLists.methods.add(method);
		
		return true;
	}
	
	public boolean visit(FieldDeclaration node) {
		Field field = new Field();
		VariableDeclarationFragment v = 
				(VariableDeclarationFragment)node.fragments().get(0);
		IVariableBinding binding = v.resolveBinding();
		if (binding == null) return true;
		field.setId(binding.getName());
		field.setLineNumBegin(positionToLineNumber(node.getStartPosition()));
		field.setLineNumEnd(positionToLineNumber(
				node.getStartPosition() + node.getLength() - 1));
		field.setPack(pack);
		field.setType(binding.getType().getName());

		Javadoc doc = node.getJavadoc();
		if (doc != null) {
			field.setComments(
					JavadocToCmt(doc, 
					field.getId(), 
					Subject.subject.field));
		}
		
		Class cls = currClass(field.getLineNumBegin(), field.getLineNumEnd());
		field.setClass(cls);
		cls.addField(field);
		codeLists.fields.add(field);
		
		return true;
	}

	public boolean visit(SingleVariableDeclaration node) {
		IVariableBinding binding = node.resolveBinding();
		if (binding == null) return true;
		Parameter param = new Parameter();
		param.setId(binding.getName());
		param.setLineNumBegin(positionToLineNumber(node.getStartPosition()));
		param.setLineNumEnd(positionToLineNumber(
				node.getStartPosition() + node.getLength() - 1));
		param.setPack(this.pack);
		// param.setComments();
		param.setType(binding.getType().getName());
		Method method = currMethod(
				param.getLineNumBegin(), param.getLineNumEnd());
		param.setMethod(method);
		if (method != null) method.addParam(param);
		codeLists.params.add(param);
		// param.setValue();
		return true;
	}
	
	public boolean visit(VariableDeclarationFragment node) {
		IVariableBinding binding = node.resolveBinding();
		
		if (binding == null || binding.isField()) {
			// Do nothing. Field has been analyzed.
			return true;
		}
		
		int nodeBegin = positionToLineNumber(node.getStartPosition());
		int nodeEnd = positionToLineNumber(
				node.getStartPosition() + node.getLength() - 1);
		Method method = currMethod(nodeBegin, nodeEnd);
		
		//System.out.println("method - " + method.getId());
		
		if (binding.isParameter() == true) {
			//System.out.println("AAAAAAAA!");
			Parameter param = new Parameter();
			param.setId(binding.getName());
			param.setLineNumBegin(nodeBegin);
			param.setLineNumEnd(nodeEnd);
			// param.setPack();
			// param.setComments();
			param.setType(binding.getType().getName());
			param.setMethod(method);
			if (method != null) method.addParam(param);
			// param.setValue();
		}
		else { 
			//System.out.println("BBBBBBBBBBBB");
			Variable var = new Variable();
			var.setId(binding.getName());
			var.setLineNumBegin(nodeBegin);
			var.setLineNumEnd(nodeEnd);
			// var.setPack();
			// var.setComments();
			var.setType(binding.getType().getName());
			var.setMethod(method);
			// var.setValue();
			if (method != null) method.addVar(var);
		}
		return true;
	}
/* TODO: analyze LineComment and BlockComment
	public boolean visit(LineComment node) {
		MyLineComment line = new MylineComment(node, source);
		line.cmt.entity = line.codeEntity(methodList, fieldList, variableList, statementList);

		return true;
	}

	public boolean visit(BlockComment node) {
		int start = positionToLineNumber(node.getStartPosition());
		int end = positionToLineNumber(start + node.getLength());
		<? extends Subject> entity = findCodeEntity(start, end);
		String str = blockToCmt(node);
		return true;
	}
*/
	private ArrayList<Comment> JavadocToCmt(Javadoc doc, String codeEntityId,
			String subject1) {
		ArrayList<Comment> cmtList = new ArrayList<Comment>();

		for (Object o: doc.tags()) {
			if (!(o instanceof TagElement)) continue;
			
			TagElement tag = (TagElement)o;
			String str = tagElementToStr(tag);
			if ("@param".equals(tag.getTagName())) {
				cmtList.addAll(StrToCmt(
						str,
						"@param",
						codeEntityId,
						Subject.subject.param,
						Subject.subject.method,
						Category.what, // category1
						"", "", ""));
			}
			else if ("@throws".equals(tag.getTagName()) 
					|| "@exception".equals(tag.getTagName())) {
				cmtList.addAll(StrToCmt(
						str,
						tag.getTagName(),
						codeEntityId,
						Subject.subject.param, // subject1
						Subject.subject.method, //subject2
						Category.done, // category1
						Category.exception, // sub-category1
						Category.property, // category2
						Category.exception)); //sub-category2
			}
			else if ("@return".equals(tag.getTagName())) {
				// System.out.println("@return " + str);
				cmtList.addAll(StrToCmt(
						str, 
						"@return",
						codeEntityId,
						Subject.subject.method, // subject1
						"", //subject2
						Category.done, // category1
						"", 
						Category.what, // category2
						"")); 
			}
			else if (tag.getTagName() == null){
				cmtList.addAll(StrToCmt(
						str, null, codeEntityId, subject1, "", "", "", "", ""));
			}
		}
		return cmtList;
	}
	
	
	private String tagElementToStr(TagElement tag) {
		String str = "";
		List<? extends ASTNode> list = tag.fragments();

		if ("@throws".equals(tag.getTagName()) 
				|| "@exception".equals(tag.getTagName())) {
			str = "Throws";
		}
		else if ("@return".equals(tag.getTagName())) {
			str = "Returns";
		}
		for (int i = 0; i < list.size(); i++) {
			Object node = list.get(i);
			if (list.get(i) instanceof TextElement) {
				TextElement text = (TextElement)list.get(i);
				str += " " + text.getText() + " ";
			}
			else if (list.get(i) instanceof Name) {
				Name nam = (Name)list.get(i);
				if (nam.isSimpleName()) {
					SimpleName simpleName = (SimpleName)nam;
					str += " " + simpleName.getIdentifier() + " ";
					if ("@param".equals(tag.getTagName()) && i == 0) {
						str += "is" + " "; 
					}
				}
				else {
					str += " " + nam.getFullyQualifiedName() + " ";
				}
			}
			else if (list.get(i) instanceof MethodRef) {
				MethodRef methodRef = (MethodRef)list.get(i);
				str += " " + methodRef.getName().getIdentifier() + " "; 
			}
			else if (list.get(i) instanceof MemberRef) {
				MemberRef memberRef = (MemberRef)list.get(i);
				str += " " + memberRef.getName().getIdentifier() + " "; 
			}
			else if (list.get(i) instanceof TagElement) {
				str += " " + tagElementToStr((TagElement)list.get(i)) + " ";
			}
		}
		
		String[] tokens = str.trim().split(" |\n");
		String ret = tokens[0];
		for (int i = 1; i < tokens.length; i++) {
			if (tokens[i].isEmpty()) continue;
			ret +=  " " + tokens[i];
		}
		//System.out.println(ret);
		return ret;
	}

	/**
	 * Separate the string str which may contain a block of comments into
	 * sentences with given labels.
	 */
	private ArrayList<Comment> StrToCmt(String str, String tag,
			String codeEntityId, String subject1, String subject2,
			String category1, String subCategory1, String category2,
			String subCategory2) {
		
		String temp = "";
		for (String s: str.trim().split(
				" |\n|<[a-zA-Z]>|<[a-zA-Z][a-zA-Z]>|<[a-zA-Z][a-zA-Z][a-zA-Z]>|<[a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z]>|</[a-zA-Z]*>")) {
			if (s.isEmpty()) continue;
			temp +=  " " + s;
		}
		if (temp.isEmpty()) return new ArrayList<Comment>();
		if (temp.charAt(temp.length()-1) != '.') temp += ".";
		str = temp;
		//System.out.println(str);
		
		ArrayList<Comment> comments = new ArrayList<Comment>();
		for (String txt: str.split("\\. ")) {
			Comment c = new Comment();
			c.setPack(pack);
			c.setTag(tag);
			c.setCodeEntityId(codeEntityId);
			c.setSubject1(subject1);
			c.setSubject2(subject2);
			c.setCategory1(category1);
			c.setSubCategory1(subCategory1);
			c.setCategory2(category2);
			c.setSubCategory2(subCategory2);
			txt = txt.trim();
			if (txt.length() == 0) continue;
			if (txt.charAt(txt.length()-1) == '.')
				txt = txt.substring(0, txt.length()-1).trim();
			c.setOrigText(txt);
			c.setCleanText(DataCleaner.clean(txt));
			c.setCleanA(c.getCleanText());
			c.setCleanB(c.getCleanText());
			comments.add(c);
		}
		return comments;
	}
	
	/* private String typeToString(Type node) {
		if (node == null) return "";
		int start = node.getStartPosition();
		int len = node.getLength();
		return source.substring(start, start + len);
	}*/

	private int positionToLineNumber(int pos) {
		int i = 0;
		int count = 1;
		while (i < pos) {
			if (source.charAt(i) == '\n') count++;
			i++;
		}
		return count;
	}
	
	private Object findCodeEntity(int start, int end) {
		for (Class cls: codeLists.classes) {
			if (start >= cls.getLineNumBegin() && end <= cls.getLineNumEnd()) {
				// Same line with a Field?
				for (Field field: cls.getFields()) {
					if (start == field.getLineNumEnd()) {
						return field;
					}
				}
				// One line before a Field?
				for (Field field: cls.getFields()) {
					if (end == field.getLineNumBegin()-1) {
						return field;
					}
				}
				// Inside a method.
				for (Method method: cls.getMethods()) {
					if (start >= method.getLineNumBegin() 
							&& end <= method.getLineNumEnd())
					// Same line with a param?
					for (Parameter param: method.getParams()) {
						if (start == param.getLineNumEnd()) {
							return param;
						}
					}
					// Same line with a variable?
					for (Variable var: method.getVariables()) {
						if (start == var.getLineNumEnd()) {
							return var;
						}
					}
					// One line before a variable?
					for (Variable var: method.getVariables()) {
						if (end == var.getLineNumBegin()-1) {
							return var;
						}
					}
					// TODO: Modify Statement
					// return statement;
				}
				
				for (Method method: cls.getMethods()) {
					if (end == method.getLineNumEnd() - 1) {
						return method;
					}
				}
				
				return cls;
			}
		}
		return null;
	}
	
	/**
	 * Get the declaring class. Parameter begin and end are line number, not 
	 * positions.
	 */
	private Class currClass(int begin, int end) {
		return codeLists.declaringClass(begin, end);
	}
	
	/**
	 * Get the declaring method. Parameter begin and end are line number, not 
	 * positions.
	 */
	private Method currMethod(int begin, int end) {
		return codeLists.declaringMethod(begin, end);
	}
}