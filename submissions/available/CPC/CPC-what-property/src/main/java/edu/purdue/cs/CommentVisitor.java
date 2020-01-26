package edu.purdue.cs;

import edu.purdue.cs.model.Class;
import edu.purdue.cs.model.Comment;
import edu.purdue.cs.model.*;
import edu.purdue.cs.util.AllFalseVisitor;
import edu.purdue.cs.util.DataCleaner;
import edu.stanford.nlp.ling.CoreLabel;
import edu.stanford.nlp.pipeline.CoreDocument;
import edu.stanford.nlp.pipeline.StanfordCoreNLP;
import org.eclipse.jdt.core.dom.*;

import java.util.*;
import java.util.stream.Collectors;

/**
 * update: change the parent class to all false visitor,
 * which means we do not analysis the children of elements
 * that we have not yet supported
 * ---- modifiedBy xxz, Dec 31, 2018
 */
class CommentVisitor extends AllFalseVisitor {
    // static List<MyLineComment> lineCommentList;
    // static List<MyBlockComment> blockCommentList;
//    private static File logFile = new File("commentLog.txt");
//    private static PrintWriter writer;
//
//    static {
//        try {
//            if (!logFile.exists()) {
//                logFile.createNewFile();
//            }
//            writer = new PrintWriter(new FileOutputStream(logFile));
//        } catch (FileNotFoundException e) {
//            e.printStackTrace();
//        } catch (IOException e) {
//            e.printStackTrace();
//        }
//    }

    private final String source;
    private final String pack;
    private Method currMethod;
    private CodeLists codeLists;
    private String retCommentsForMethod;
    private Map<String, List<Comment>> paramMap = new HashMap<>();
    private int paramRank;

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

    @Override
    public boolean visit(EnhancedForStatement node) {
        return true;
    }

    @Override
    public boolean visit(ForStatement node) {
        return true;
    }

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
        codeLists.getClasses().add(cls);
        return true;

    }

    public boolean visit(MethodDeclaration node) {
        paramRank = 1;
        IMethodBinding binding = node.resolveBinding();
        if (binding == null) {
            return false;
        }

        Method method = new Method();
        method.setId(binding.toString());
        method.setLineNumBegin(positionToLineNumber(node.getStartPosition()));
        method.setLineNumEnd(positionToLineNumber(
                node.getStartPosition() + node.getLength() - 1));
        method.setPack(pack);
        method.setRetType(binding.getReturnType().getName());

        Javadoc doc = node.getJavadoc();
        if (doc != null) {
            ArrayList<Comment> comments = JavadocToCmt(doc,
                    method.getId(),
                    Subject.subject.method);
            method.setComments(
                    comments);
            List<Comment> exceptions = comments.stream()
                    .filter(comment -> comment.getTag().equals("@throws"))
                    .collect(Collectors.toList());
            method.setExceptions(exceptions);
            method.setHasComment(!comments.isEmpty());
        }


        Class cls = currClass(method.getLineNumBegin(), method.getLineNumEnd());
        cls.addMethod(method);
        method.setClass(cls);
        currMethod = method;
        currMethod.setReturnComment(retCommentsForMethod);
        retCommentsForMethod = null;
        return true;
    }

    @Override
    public void endVisit(MethodDeclaration node) {
        super.endVisit(node);
        if (currMethod != null && currMethod.getReturnComment() != null) {
            RawComment returnComment = new RawComment(currMethod, currMethod.getReturnComment());
            returnComment.parse();
            currMethod.setReturnCommentToMatch(returnComment);
        }
        currMethod = null;
        paramMap.clear();
        paramRank = 0;
    }

    public boolean visit(FieldDeclaration node) {
        Field field = new Field();
        VariableDeclarationFragment v =
                (VariableDeclarationFragment) node.fragments().get(0);
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
            field.setHasComment(true);
            field.setComments(
                    JavadocToCmt(doc,
                            field.getId(),
                            Subject.subject.field));

        }

        Class cls = currClass(field.getLineNumBegin(), field.getLineNumEnd());
        field.setClass(cls);
        cls.addField(field);
//        codeLists.fields.add(field);

        return true;
    }

    public boolean visit(SingleVariableDeclaration node) {
        if (currMethod == null) return false;
        IVariableBinding binding = node.resolveBinding();
        if (binding == null) return true;
        int lineNumBegin = positionToLineNumber(node.getStartPosition());
        int lineNumEnd = positionToLineNumber(node.getStartPosition() + node.getLength() - 1);
        if (binding.isParameter()) {
            Parameter param = new Parameter();
            String paramName = binding.getName();
            param.setId(paramName);
            param.setRank(paramRank++);
            param.setLineNumBegin(lineNumBegin);
            param.setLineNumEnd(lineNumEnd);
            param.setPack(this.pack);
            // param.setComments();
            param.setType(binding.getType().getName());
            List<Comment> paramComments = paramMap.get(paramName);
            if (paramComments != null && !paramComments.isEmpty()) {
                param.setHasComment(true);
                param.setComments(new ArrayList<>(paramComments));
                List<Property> properties = generateProperty(paramComments.get(0));
                param.setProperties(properties);
                List<String> describes = paramComments
                        .stream()
                        .map(Comment::getOrigText)
                        .map(this::getNounDescribes)
                        .flatMap(Collection::stream)
                        .collect(Collectors.toList());
                if (describes.size() > 1) {
                    describes = new ArrayList<>(describes.subList(0, describes.size() - 1));
                }
                param.setNounDescribes(describes);
            }
            Method method = currMethod;
            param.setMethod(method);
            method.addParam(param);
        } else {
            Variable var = new Variable();
            var.setId(binding.getName());
            var.setLineNumBegin(lineNumBegin);
            var.setLineNumEnd(lineNumEnd);
            // var.setPack();
            // var.setComments();
            var.setType(binding.getType().getName());
            var.setMethod(currMethod);
            // var.setValue();
            currMethod.addVar(var);
        }
        // param.setValue();
        return true;
    }

    @Override
    public boolean visit(VariableDeclarationFragment node) {
        if (currMethod == null) return false;
        int lineNumBegin = positionToLineNumber(node.getStartPosition());
        int lineNumEnd = positionToLineNumber(node.getStartPosition() + node.getLength() - 1);
        Variable variable = new Variable();
        variable.setId(node.getName().toString());
        variable.setLineNumBegin(lineNumBegin);
        variable.setLineNumEnd(lineNumEnd);
        variable.setMethod(currMethod);
        currMethod.addVar(variable);

        return super.visit(node);
    }

    @Override
    public boolean visit(VariableDeclarationExpression node) {
        return true;
    }

    @Override
    public boolean visit(VariableDeclarationStatement node) {
        return true;
    }

    private List<Property> generateProperty(Comment comment) {
        String commentOrigText = comment.getOrigText();
        Property property = new Property();
        if (commentOrigText.contains("null")) {
            property.setProperty("null");
            String might = ".*((can|may) be|possibly) null.*";
            String mustNot = ".*((must|should) not|cannot) be null.*|.* not? null.*";
            String mayNot = ".*may not be null.*";
            if (commentOrigText.matches(might)) {
                property.setPossibility(Possibility.CAN);
            } else if (commentOrigText.matches(mustNot)) {
                property.setPossibility(Possibility.MUSTNT);
            } else if (commentOrigText.matches(mayNot)) {
                property.setPossibility(Possibility.MAY_NOT);
            } else {
                property.setPossibility(Possibility.DEFAULT);
            }
            return Collections.singletonList(property);
        }
        return new ArrayList<>();
    }

    private ArrayList<Comment> JavadocToCmt(Javadoc doc, String codeEntityId,
                                            String subject1) {
        ArrayList<Comment> cmtList = new ArrayList<>();

        //"The first tag element of a typical doc comment represents
        //	 * all the material before the first explicit doc tag;"
        for (Object o : doc.tags()) {
            if (!(o instanceof TagElement)) continue;

            TagElement tag = (TagElement) o;
            String str = tagElementToStr(tag);

            if ("@param".equals(tag.getTagName())) {
                String paramName = ((TagElement) o).fragments().get(0).toString();
                ArrayList<Comment> comments = StrToCmt(str, "@param", codeEntityId, Subject.subject.param,
                        Subject.subject.method, Category.what, "", "", "");
                paramMap.put(paramName, comments);
            } else if ("@throws".equals(tag.getTagName()) || "@exception".equals(tag.getTagName())) {
                cmtList.addAll(StrToCmt(
                        str,
                        "@throws",
                        codeEntityId,
                        Subject.subject.param, // subject1
                        Subject.subject.method, //subject2
                        Category.done, // category1
                        Category.exception, // sub-category1
                        Category.property, // category2
                        Category.exception)); //sub-category2
            } else if ("@return".equals(tag.getTagName())) {
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
                retCommentsForMethod = cleanString(str.replace("Returns", ""));

            } else if (tag.getTagName() == null) {
                cmtList.addAll(StrToCmt(
                        str, "", codeEntityId, subject1, "", "", "", "", ""));
            }
        }
        return cmtList;
    }


    private String tagElementToStr(TagElement tag) {
        String str = "";
        List<? extends ASTNode> list = tag.fragments();

        if ("@throws".equals(tag.getTagName())) {
            str = "Throws";
        } else if ("@return".equals(tag.getTagName())) {
            str = "Returns";
        }
        for (int i = 0; i < list.size(); i++) {
            if ("@param".equals(tag.getTagName()) && i == 0) {
                continue;
            }

            Object node = list.get(i);
            if (list.get(i) instanceof TextElement) {
                TextElement text = (TextElement) list.get(i);
                str += " " + text.getText() + " ";
            } else if (list.get(i) instanceof Name) {
                Name nam = (Name) list.get(i);
                if (nam.isSimpleName()) {
                    SimpleName simpleName = (SimpleName) nam;
                    str += " " + simpleName.getIdentifier() + " ";
                    if ("@param".equals(tag.getTagName()) && i == 0) {
//                        str += "is" + " ";
                    }
                } else {
                    str += " " + nam.getFullyQualifiedName() + " ";
                }
            } else if (list.get(i) instanceof MethodRef) {
                MethodRef methodRef = (MethodRef) list.get(i);
                str += " " + methodRef.getName().getIdentifier() + " ";
            } else if (list.get(i) instanceof MemberRef) {
                MemberRef memberRef = (MemberRef) list.get(i);
                str += " " + memberRef.getName().getIdentifier() + " ";
            } else if (list.get(i) instanceof TagElement) {
                str += " " + tagElementToStr((TagElement) list.get(i)) + " ";
            }
        }

        String[] tokens = str.trim().split(" |\n");
        String ret = tokens[0];
        for (int i = 1; i < tokens.length; i++) {
            if (tokens[i].isEmpty()) continue;
            ret += " " + tokens[i];
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

        String temp = cleanString(str);
//        writer.println(temp);
//        writer.flush();
        if (temp.isEmpty()) return new ArrayList<Comment>();
        if (temp.charAt(temp.length() - 1) != '.') temp += ".";
        str = temp;
        //System.out.println(str);

        ArrayList<Comment> comments = new ArrayList<Comment>();
        for (String txt : str.split("\\. ")) {
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
            if (txt.charAt(txt.length() - 1) == '.')
                txt = txt.substring(0, txt.length() - 1).trim();
            c.setOrigText(txt);
            c.setCleanText(DataCleaner.clean(txt));
            c.setCleanA(c.getCleanText());
            c.setCleanB(c.getCleanText());
            comments.add(c);
        }
        return comments;
    }

    private String cleanString(String str) {
        String temp = "";
        String DELIMITER = " |\n|<[a-zA-Z]*>|</[a-zA-Z]*>";
        List<String> strings = Arrays.stream(str.trim().split(DELIMITER))
                .map(s -> s.split(DELIMITER))
                .flatMap(Arrays::stream)
                .map(s -> s.split(DELIMITER))
                .flatMap(Arrays::stream)
                .collect(Collectors.toList());
        for (String s : strings) {
            if (s.isEmpty()) continue;
            temp += " " + s;
        }
        return temp;
    }
	
	/* private String typeToString(Type node) {
		if (node == null) return "";
		int start = node.getStartPosition();
		int len = node.getLength();
		return source.substring(start, start + len);
	}*/

    /**
     * find the line number of given position
     *
     * @param pos the offset to the begin of the src
     * @return the line number
     */
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
        for (Class cls : codeLists.getClasses()) {
            if (start >= cls.getLineNumBegin() && end <= cls.getLineNumEnd()) {
                // Same line with a Field?
                for (Field field : cls.getFields()) {
                    if (start == field.getLineNumEnd()) {
                        return field;
                    }
                }
                // One line before a Field?
                for (Field field : cls.getFields()) {
                    if (end == field.getLineNumBegin() - 1) {
                        return field;
                    }
                }
                // Inside a method.
                for (Method method : cls.getMethods()) {
                    if (start >= method.getLineNumBegin()
                            && end <= method.getLineNumEnd())
                        // Same line with a param?
                        for (Parameter param : method.getParams()) {
                            if (start == param.getLineNumEnd()) {
                                return param;
                            }
                        }
                    // Same line with a variable?
                    for (Variable var : method.getVariables()) {
                        if (start == var.getLineNumEnd()) {
                            return var;
                        }
                    }
                    // One line before a variable?
                    for (Variable var : method.getVariables()) {
                        if (end == var.getLineNumBegin() - 1) {
                            return var;
                        }
                    }
                    // TODO: Modify Statement
                    // return statement;
                }

                for (Method method : cls.getMethods()) {
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


    private List<String> getNounDescribes(String rawComment) {
        Properties props = new Properties();
        // set the list of annotators to run
        props.setProperty("annotators", "tokenize,ssplit,pos,lemma");
        // set a property for an annotator, in this case the coref annotator is being set to use the neural algorithm
        props.setProperty("coref.algorithm", "neural");
        // build pipeline
        StanfordCoreNLP pipeline = new StanfordCoreNLP(props);
        // create a document object
        CoreDocument document = new CoreDocument(rawComment);
        // annnotate the document
        pipeline.annotate(document);

        return document.tokens()
                .stream()
                .filter(t -> t.tag().contains("NN"))
                .map(CoreLabel::value)
                .collect(Collectors.toList());

    }

//    /**
//     * Get the declaring method. Parameter begin and end are line number, not
//     * positions.
//     */
//    private Method currMethod(int begin, int end) {
//        return codeLists.declaringMethod(begin, end);
//    }
}
