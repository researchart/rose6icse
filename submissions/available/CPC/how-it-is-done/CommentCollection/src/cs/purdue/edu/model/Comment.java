package cs.purdue.edu.model;

import edu.stanford.nlp.trees.GrammaticalStructure;
import edu.stanford.nlp.trees.TreeGraphNode;

public class Comment {
	private String pack;
	private String tag; // @param, @throws, ......
	private String codeEntityId;
	
	private String category1;
	private String category2;
	private String subCategory1;
	private String subCategory2;
	private String subject1;
	private String subject2;
	
	private String origText; //the original comment text
	private String cleanText; //after cleaning like removing stop words etc. may not be used. currently we can just use the python script
	private String cleanA;
	private String cleanB;
	
	private GrammaticalStructure gs;

	public void setPack(String pack) {
		this.pack = pack;
	}
	
	public String getPack() {
		return this.pack;
	}
	
	public void setTag(String tag) {
		this.tag = tag;
	}
	
	public String getTag() {
		return this.tag;
	}
	
	public void setCodeEntityId(String codeEntityId) {
		this.codeEntityId  = codeEntityId;
	}
	public String getCodeEntityId() {
		return this.codeEntityId;
	}
	
	public void setCategory1(String category1) {
		this.category1  = category1;
	}
	public String getCategory1() {
		return this.category1;
	}
	
	public void setCategory2(String category2) {
		this.category2  = category2;
	}
	public String getCategory2() {
		return this.category2;
	}
	
	public void setSubCategory1(String subCategory1) {
		this.subCategory1  = subCategory1;
	}
	public String getSubCategory1() {
		return this.subCategory1;
	}
	
	public void setSubCategory2(String subCategory2) {
		this.subCategory2  = subCategory2;
	}
	public String getSubCategory2() {
		return this.subCategory2;
	}
	
	public void setSubject1(String subject1) {
		this.subject1  = subject1;
	}
	public String getSubject1() {
		return this.subject1;
	}
	
	public void setSubject2(String subject2) {
		this.subject2  = subject2;
	}
	public String getSubject2() {
		return this.subject2;
	}
	
	public void setOrigText(String origText) {
		this.origText  = origText;
		//this.textA = cleanForCorpusA()
	}
	public String getOrigText() {
		return this.origText;
	}
	
	public void setCleanText(String cleanText) {
		this.cleanText  = cleanText;
	}
	public String getCleanText() {
		return this.cleanText;
	}
	
	public void setGrammaticalStructure(GrammaticalStructure gs) {
		this.gs = gs;
	}
	public GrammaticalStructure getGrammaticalStructure() {
		return this.gs;
	}
	
	public void setCleanA(String cleanA) {
		this.cleanA  = cleanA;
	}
	public String getCleanA() {
		return this.cleanA;
	}
	
	public void setCleanB(String cleanB) {
		this.cleanB  = cleanB;
	}
	public String getCleanB() {
		return this.cleanB;
	}
	
}
