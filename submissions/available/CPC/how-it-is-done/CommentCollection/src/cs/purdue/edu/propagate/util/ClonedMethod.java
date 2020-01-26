package cs.purdue.edu.propagate.util;

import cs.purdue.edu.model.Method;

public class ClonedMethod {
	private String file;
	private int startline;
	private int endline;
	private int pcid;
	
	public ClonedMethod(String file, int startline, int endline, int pcid) {
		this.file = file.substring(8).replace('/', '\\');
		this.startline = startline;
		this.endline = endline;
		this.pcid = pcid;
	}

	public String getFile() {
		return file;
	}

	public void setFile(String file) {
		this.file = file;
	}

	public int getStartline() {
		return startline;
	}

	public void setStartline(int startline) {
		this.startline = startline;
	}

	public int getEndline() {
		return endline;
	}

	public void setEndline(int endline) {
		this.endline = endline;
	}

	public int getPcid() {
		return pcid;
	}

	public void setPcid(int pcid) {
		this.pcid = pcid;
	}
}
