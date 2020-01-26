package cs.purdue.edu.propagate.util;

import java.util.ArrayList;
import java.util.PriorityQueue;
import java.util.Comparator;


public class Revision {
	private PriorityQueue<CodeChange> changeList = new PriorityQueue<CodeChange>(
			new Comparator<CodeChange>() {
				@Override
				public int compare(CodeChange o1, CodeChange o2) {
					if (o1.begin < o2.begin) return 1;
					if (o1.begin > o2.begin) return -1;
					return 0;
				}
	});
	
	Revision() {}
	
	public void addChange(int begin, int len, String newStr) {
		changeList.add(new CodeChange(begin, len, newStr));
	}
	
	public String reviseAll(String src, int offset) {
		String ret = src;
		while (!changeList.isEmpty()) {
			CodeChange c = changeList.poll();
			System.out.println("\n(" + c.begin + ") " + ret.substring(c.begin + offset, c.begin + offset + c.len) + "\n=>\n" + c.newStr + "\n");
			ret = ret.substring(0, c.begin + offset) + c.newStr
					+ ret.substring(c.begin + c.len + offset);
		}
		return ret;
	}
}
