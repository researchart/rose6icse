package cs.purdue.edu.propagate.util;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashSet;
import java.util.Set;

public class CommentCmpTool {
	private static String projectName = "joda";
	private static String dir = "C:\\Projects\\data_how-it-is-done\\0.1\\";
	private static String finName = dir + projectName + ".txt";
	private static String foutName = dir + projectName + "_result.txt";
	
	
	public static void main(String[] args) throws IOException {
		// TODO Auto-generated method stub
		BufferedReader reader = new BufferedReader(new FileReader(finName));
		BufferedWriter writer = new BufferedWriter(new FileWriter(foutName));
		int mtdNum = 0; // method number
		int[] cmtNum = new int[100];   // comment number
		String[][] cmt = new String[100][100];
		
		int existCmtNum = 0;
		int propCmtNum = 0;
		int newCmtNum = 0;
		Set<String> mtdName  = new HashSet<String>();
		mtdName.clear();
		int same = 0;
		int otherNum = 0;
		
		String str = reader.readLine();
		while (true) {
			//System.out.println("str = " + str);
			if ("*".equals(str) || "-".equals(str)) {
				// Compare comments
				
				// New 
				//for (int i = 1; i <= mtdNum; i++) propCmtNum += cmtNum[i] * (mtdNum - 1);
				
				// Compare inside pairs
				for (int i = 1; i < mtdNum; i++) {	// method_i
					existCmtNum += cmtNum[i];
					for (int j = 1; j <= mtdNum; j++) {	//method_j
						if (i == j) continue;
						
						propCmtNum += cmtNum[i];	// #pc
						if (cmtNum[j] == 0) {
							newCmtNum += cmtNum[i];	  // #new
							continue;
						}
						
						for (int k = 1; k <= cmtNum[i]; k++) {
							boolean flag = false;   	// have same
							for (int l = 1; l <= cmtNum[j]; l++) {
								if (cmt[i][k].equals(cmt[j][l]))
									flag = true;
							}
							
							if (flag) {				// dist = 0, no need to compute distance.
								same++;
								continue;
							}
							// otherwise, find the most similar one.
							int min = findMinDist(cmt[i][k], cmt[j], cmtNum[j]);
							writer.write(cmt[i][k] + "\n");
							writer.write(cmt[j][min] + "\n");
							otherNum++;
						}
						
						
						
					}
				}
				// initialization for a new pair
				mtdNum = 0;
				if ("-".equals(str)) break;
			}
			else if ("#".equals(str)) {		// str == "#"
				mtdNum++;
				cmtNum[mtdNum] = 0;
				str = reader.readLine();    // Method's name & line.
				// mtdName.add(str.split(" ")[0]);   // Count the number of related classes.
				mtdName.add(str);   // Count the number of related methods.
			}
			else {			// comment
				System.out.println(cmtNum[mtdNum] + ", " + mtdNum);
				cmt[mtdNum][++cmtNum[mtdNum]] = str;
			}
			str = reader.readLine();
		}
		
		System.out.println("#m = " + mtdName.size());
		System.out.println("#ec = " + existCmtNum);
		int tot = same + newCmtNum + otherNum;
		System.out.println("#pc = " + propCmtNum + "   " + tot);
		System.out.println("dist=0 = " + same);
		System.out.println("dist>0 = " + otherNum);
		System.out.println("#new = " + newCmtNum);
		
		
		
		
		reader.close();
		writer.close();
	}
	
	static private int findMinDist(String str, String[] cmt, int n) {
		int ret = 1;
		int min = distance(str.split(" "), cmt[1].split(" "));
		for (int i = 2; i <= n; i++) {
			int temp = distance(str.split(" "), cmt[i].split(" "));
			if (temp < min) {
				min = temp;
				ret = i;
			}
		}
		return ret;
	}
	
	static private int distance(String[] s1, String[] s2) {
		int l1 = s1.length;
		int l2 = s2.length;
		int[][] f = new int[100][100];
		int ret = 0;
		for (int i = 0; i < l1; i++) {
			for (int j = 0; j < l2; j++) {
				f[i][j] = 0;
				if (i-1 >= 0) f[i][j] = max(f[i-1][j], f[i][j]);
				if (j-1 >= 0) f[i][j] = max(f[i][j-1], f[i][j]);
				
				if (s1[i].equals(s2[j])) {
					if (i == 0 || j == 0) f[i][j] = max(1, f[i][j]);
					else f[i][j] = max(f[i-1][j-1], f[i][j]);
				}
				
				ret = max(ret, f[i][j]);
			}
		}
		return ret;
	}
	
	static private int max(int a, int b) {
		if (a > b) return a;
		return b;
	}

}
