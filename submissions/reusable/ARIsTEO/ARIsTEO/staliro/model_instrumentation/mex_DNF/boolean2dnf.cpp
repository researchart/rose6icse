/*=================================================================
 * boolean2dnf.cpp 
 * 
 * Function 'boolean2dnf' transforms any boolean formula into Disjunctive 
 * Normal Form (DNF). It reads the boolean formula as a string and 
 * returns the DNF formula as a string.
 * 
 * The brief description of the algorithm is as follows:
 * 1- Create Negation Normal form of the boolean formula.
 * 2- Iteratively transform ( a AND (b OR c) ) => (a AND b) OR (b AND c)
 *    until no disjunction/OR remains as a subformula of a conjunction/AND.
 *
 * Copyright (c) 2017  Georgios Fainekos - ASU	
 * Copyright (c) 2017  Adel Dokhanchi - ASU		
 *=================================================================*/


#include <stdio.h>
#include <cstring>/* strlen */
#include <string> 
#include <vector>
#include <stack>
#include "mex.h"

/* Instantiate a static class constuctor */
class fileresource {
public:
  fileresource() { fp=fopen("dnf.txt","w");}
  ~fileresource() { fclose(fp); }
  void close() { fclose(fp); }
  FILE *fp;
};

struct BOOLNODE{
    std::string  text;
    int textIndex;
	unsigned int nodeIndex;
    struct BOOLNODE *parent;
    struct BOOLNODE *left;
    struct BOOLNODE *right;
	bool processed;
};

class boolTree{
public:
    BOOLNODE* root;
	BOOLNODE* clone;
    std::vector<std::string> tokenFormula;
	std::vector<int> tokenIndex;
    std::string   textFormula;
    std::string   textNNF;
    std::vector<BOOLNODE*> nodeList;
    std::vector<BOOLNODE*> conjuncts;
    std::vector<BOOLNODE*> literals;
    std::vector<unsigned int>  openParan;
    std::vector<unsigned int>  closeParan;
    std::stack<unsigned int> mystack;
    void  createNodes();
    void  printNodes();
    void  checkParan();
    void  toGraphViz(FILE *);
    void  toGraphVizRoot(BOOLNODE *nodePtr,FILE *);
    void  NNF(BOOLNODE *);
    void  NOT(BOOLNODE *);
    BOOLNODE*  copyTree(BOOLNODE* , BOOLNODE*);
    bool  checkDNF(BOOLNODE*);
    void  countConjuncts(BOOLNODE *);
    void  countLiterals(BOOLNODE *);
    BOOLNODE* createBooleanTree(unsigned int,unsigned int);
    boolTree(){mexPrintf("Boolean tree is created\n");root=NULL;}
    ~boolTree(){ mexPrintf("Boolean tree is deleted\n");}
};

void  boolTree::createNodes(){
    unsigned int i;
    BOOLNODE *node;
    std::string open("(");
    std::string close(")");
    for(i=0;i<tokenFormula.size();i++){ 
		tokenIndex.push_back(-1);
        if( tokenFormula[i].compare("(")!=0 && tokenFormula[i].compare(")")!=0 ){
			node = new BOOLNODE;
            node->text=tokenFormula[i];
			node->textIndex = i;
			node->nodeIndex = (unsigned int)nodeList.size();
			node->left = NULL;
			node->right = NULL;
			node->parent = NULL;
			node->processed = false;
            nodeList.push_back(node);
			tokenIndex[i] = (int) nodeList.size() - 1;
        }
        else if(tokenFormula[i].compare("(")==0){
            openParan.push_back(i);
        }
    }
}

void  boolTree::printNodes(){
    unsigned int i;
    for(i=0;i<nodeList.size();i++){
         if(nodeList[i]->left!=NULL){
             mexPrintf("%s <- ",nodeList[i]->left->text.c_str());
         }
         mexPrintf("%s",nodeList[i]->text.c_str());
         if(nodeList[i]->right!=NULL){
             mexPrintf(" -> %s",nodeList[i]->right->text.c_str());
         }
         mexPrintf("\n");
    }
}

void  boolTree::toGraphViz(FILE *f){
    unsigned int i;
    for(i=0;i<nodeList.size();i++){
         if(nodeList[i]->left!=NULL){
			 fprintf(f, "  \"%s(%d)\" -> \"%s(%d)\"\n", nodeList[i]->text.c_str(), nodeList[i]->nodeIndex, nodeList[i]->left->text.c_str(), nodeList[i]->left->nodeIndex);
         }
		 if (nodeList[i]->right != NULL){
			 fprintf(f, "  \"%s(%d)\" -> \"%s(%d)\"\n", nodeList[i]->text.c_str(), nodeList[i]->nodeIndex, nodeList[i]->right->text.c_str(), nodeList[i]->right->nodeIndex);
         }
    }
   	fputs("}\n", f);
    fclose(f);
}


void  boolTree::checkParan(){
    unsigned int i,j;
    std::string open("(");
    std::string close(")");
    for(i=0;i<openParan.size();i++){
        if (mystack.empty()){
            mystack.push(openParan[i]);
            j=openParan[i];
            while(j<tokenFormula.size() && !mystack.empty()){
                j++;
                if(tokenFormula[j].compare(")")==0){
                    mystack.pop();
                }
                else if(tokenFormula[j].compare("(")==0){
                    mystack.push(j);
                }
            }
            if(tokenFormula[j].compare(")")==0){
                closeParan.push_back(j);
            }
            else{
                mexErrMsgIdAndTxt( "MATLAB:mex4bool2dnf",
                "Error on empty paranthesis.");
            }
        }
        else{
            mexErrMsgIdAndTxt( "MATLAB:mex4bool2dnf",
                "Stack must be empty.");
        }
    }
}

BOOLNODE* boolTree::createBooleanTree(unsigned int low,unsigned int high){
    unsigned int i,j,k=0;
    unsigned int right,left;
    BOOLNODE* nodePtr=NULL;
	BOOLNODE* nodeParanthesis = NULL;
	BOOLNODE* nodeLeft = NULL;
	BOOLNODE* nodeRight = NULL;
	/*std::string open("(");
	std::string close(")");
    std::string and("&");
    std::string or("|");
    std::string not("!");  */
    if( tokenFormula[low].compare("(")==0 ){
        for(i=0;i<openParan.size();i++){
            if(low==openParan[i]){
                j=i;
                break;
            }
        }
		if (closeParan[j] == high)
			return createBooleanTree(low+1,closeParan[j]-1);
		else{
			nodeParanthesis = createBooleanTree(low + 1, closeParan[j] - 1);
			tokenIndex[low] = nodeParanthesis->nodeIndex;
			tokenIndex[closeParan[j]] = nodeParanthesis->nodeIndex;
        }
    }
	if (low == high){
		j = tokenIndex[high];
		return nodeList[j];
	}

    for(i=low;i<=high;i++){
		if (tokenFormula[i].compare("!") == 0){
			j=tokenIndex[i];
			if (nodeList[j]->text.compare("!") != 0)
				mexErrMsgIdAndTxt("MATLAB:mexatexit:invalidNumInputs","error on token index.");
			if (nodeList[j]->processed == true)
				continue;
			if (tokenFormula[nodeList[j]->textIndex + 1].compare("(") != 0){
				nodeList[j]->processed = true;
				if (nodeList[j + 1]->parent == NULL){
					nodeList[j + 1]->parent = nodeList[j];
                    nodeList[j]->right=nodeList[j+1];
                }
                else{
                    mexErrMsgIdAndTxt( "MATLAB:mexatexit:invalidNumInputs","node for NOT is already processed.");
                }
            }
            else{
                left=nodeList[j]->textIndex+1;
                if(tokenIndex[left]==-1){
                    for(k=0;k<openParan.size();k++){
                        if(left==openParan[k]){
                            right=k;
                            break;
                        }
                    }
                    nodeParanthesis = createBooleanTree(left + 1, closeParan[right] - 1);
					tokenIndex[left] = nodeParanthesis->nodeIndex;
					tokenIndex[closeParan[right]] = nodeParanthesis->nodeIndex;
                }
                else
					nodeParanthesis=nodeList[tokenIndex[left]];
				nodeParanthesis->parent = nodeList[j];
				nodeList[j]->right = nodeParanthesis;
				nodeList[j]->processed = true;
            }
        }
    }
    for(i=low;i<=high;i++){
		if (tokenFormula[i].compare("&") == 0){
			j = tokenIndex[i];
			if (nodeList[j]->text.compare("&") != 0)
				mexErrMsgIdAndTxt("MATLAB:mexatexit:invalidNumInputs","error on token index.");
			if (nodeList[j]->processed == true)
				continue;
			if (tokenFormula[nodeList[j]->textIndex - 1].compare(")") == 0){
				right = nodeList[j]->textIndex - 1;
				if (tokenIndex[right]==-1){
                     for(k=0;k<openParan.size();k++){
                        if(right==closeParan[k]){
                            left=k;
                            break;
                        }
                    }
					nodeLeft = createBooleanTree(openParan[left] + 1, right - 1);
					tokenIndex[openParan[left]] = nodeLeft->nodeIndex;
					tokenIndex[right] = nodeLeft->nodeIndex;
                }
                else
					nodeLeft = nodeList[tokenIndex[right]];
			}
			else{
				nodeLeft = nodeList[j - 1];
			}
			if (tokenFormula[nodeList[j]->textIndex + 1].compare("(") != 0){
				nodeList[j]->processed = true;
				if (nodeLeft->parent == NULL){
					nodeLeft->parent = nodeList[j];
					nodeList[j]->left = nodeLeft;
                }
                else{
					nodePtr = nodeLeft->parent;
                    while(nodePtr->parent!=NULL)
                        nodePtr=nodePtr->parent;
                    nodePtr->parent=nodeList[j];
					nodeList[j]->left = nodePtr;
                }
				if (nodeList[j + 1]->parent == NULL){
					nodeList[j + 1]->parent = nodeList[j];
					nodeList[j]->right = nodeList[j + 1];
                }
                else{
					nodePtr = nodeList[j + 1]->parent;
                    while(nodePtr->parent!=NULL)
                        nodePtr=nodePtr->parent;
                    nodePtr->parent=nodeList[j];
					nodeList[j]->right = nodePtr;
                }
            }
            else{
				left = nodeList[j]->textIndex + 1;
                if(tokenIndex[left]==-1){
       				for (k = 0; k<openParan.size(); k++){
    					if (left == openParan[k]){
        					right = k;
            				break;
                		}
                    }
                    nodeRight = createBooleanTree(left + 1, closeParan[right] - 1);
					tokenIndex[left] = nodeRight->nodeIndex;
					tokenIndex[closeParan[right]] = nodeRight->nodeIndex;
                }
				else
					nodeRight = nodeList[tokenIndex[left]];
				nodeList[j]->processed = true;
				if (nodeRight->parent == NULL){
					nodeRight->parent = nodeList[j];
					nodeList[j]->right = nodeRight;
                }
				else{
					nodePtr = nodeRight->parent;
					while (nodePtr->parent != NULL)
						nodePtr = nodePtr->parent;
					nodePtr->parent = nodeList[j];
					nodeList[j]->right = nodePtr;
				}

				if (nodeLeft->parent == NULL){
					nodeLeft->parent = nodeList[j];
					nodeList[j]->left = nodeLeft;
				}
				else{
					nodePtr = nodeLeft->parent;
					while (nodePtr->parent != NULL)
						nodePtr = nodePtr->parent;
					nodePtr->parent = nodeList[j];
					nodeList[j]->left = nodePtr;
				}
			}
        }
    }
    for(i=low;i<=high;i++){
		if (tokenFormula[i].compare("|") == 0){
			j = tokenIndex[i];
			if (nodeList[j]->text.compare("|") != 0)
				mexErrMsgIdAndTxt("MATLAB:mexatexit:invalidNumInputs","error on token index.");
			if (nodeList[j]->processed == true)
				continue;
			if (tokenFormula[nodeList[j]->textIndex - 1].compare(")") == 0){
				right = nodeList[j]->textIndex - 1;
				if (tokenIndex[right]==-1){
                     for(k=0;k<openParan.size();k++){
                        if(right==closeParan[k]){
                            left=k;
                            break;
                        }
                    }
					nodeLeft = createBooleanTree(openParan[left] + 1, right - 1);
					tokenIndex[openParan[left]] = nodeLeft->nodeIndex;
					tokenIndex[right] = nodeLeft->nodeIndex;
                }
				else
					nodeLeft = nodeList[tokenIndex[right]];
			}
			else{
				nodeLeft = nodeList[j - 1];
			}
			if (tokenFormula[nodeList[j]->textIndex + 1].compare("(") != 0){
				nodeList[j]->processed = true;
				if (nodeLeft->parent == NULL){
					nodeLeft->parent = nodeList[j];
					nodeList[j]->left = nodeLeft;
                }
                else{
					nodePtr = nodeLeft->parent;
                    while(nodePtr->parent!=NULL)
                        nodePtr=nodePtr->parent;
                    nodePtr->parent=nodeList[j];
					nodeList[j]->left = nodePtr;
                }
				if (nodeList[j + 1]->parent == NULL){
					nodeList[j + 1]->parent = nodeList[j];
					nodeList[j]->right = nodeList[j + 1];
                }
                else{
					nodePtr = nodeList[j + 1]->parent;
                    while(nodePtr->parent!=NULL)
                        nodePtr=nodePtr->parent;
                    nodePtr->parent=nodeList[j];
					nodeList[j]->right = nodePtr;
                }
            }
            else{
				left = nodeList[j]->textIndex + 1;
                if(tokenIndex[left]==-1){
       				for (k = 0; k<openParan.size(); k++){
    					if (left == openParan[k]){
        					right = k;
            				break;
                		}
                    }
                    nodeRight = createBooleanTree(left + 1, closeParan[right] - 1);
					tokenIndex[left] = nodeRight->nodeIndex;
					tokenIndex[closeParan[right]] = nodeRight->nodeIndex;
                }
				else
					nodeRight = nodeList[tokenIndex[left]];
				nodeList[j]->processed = true;
				if (nodeRight->parent == NULL){
					nodeRight->parent = nodeList[j];
					nodeList[j]->right = nodeRight;
                }
				else{
					nodePtr = nodeRight->parent;
					while (nodePtr->parent != NULL)
						nodePtr = nodePtr->parent;
					nodePtr->parent = nodeList[j];
					nodeList[j]->right = nodePtr;
				}
				if (nodeLeft->parent == NULL){
					nodeLeft->parent = nodeList[j];
					nodeList[j]->left = nodeLeft;
				}
				else{
					nodePtr = nodeLeft->parent;
					while (nodePtr->parent != NULL)
						nodePtr = nodePtr->parent;
					nodePtr->parent = nodeList[j];
					nodeList[j]->left = nodePtr;
				}
			}
        }
    }
    nodePtr=NULL;
    k=0;
    for(i=low;i<=high;i++){
		j=tokenIndex[i];
		if (j<nodeList.size() && nodeList[j]->parent == NULL){
            k++;
            nodePtr=nodeList[j];
        }
    }
    if(k!=1)         mexErrMsgIdAndTxt( "MATLAB:mexatexit:invalidNumInputs","root is not found.");
    return nodePtr;
}

std::vector<std::string> split(const char *str, char c = ' ')
{
    std::vector<std::string> result;
    do
    {
        const char *begin = str;
        
        while(*str != c && *str)
            str++;
        
		if (0 != *begin && *begin != c)
			result.push_back(std::string(begin, str));
        
    } while (0 != *str++);
    return result;
}

void boolTree::NOT(BOOLNODE *nodePtr){
    BOOLNODE *nextPtr;
    BOOLNODE *notNode;
    /*std::string and("&");
    std::string or("|");
    std::string not("!");  */
    if(nodePtr==NULL)
        mexErrMsgIdAndTxt( "MATLAB:mexatexit:invalidNumInputs","NULL pointer is reached in NOT.");
    if( nodePtr->text.compare("|") == 0 ) {
        nodePtr->text.assign("&");
        NOT(nodePtr->left);
        NOT(nodePtr->right);
    }
    else if( nodePtr->text.compare("&") == 0 ) {
        nodePtr->text.assign("|");
        NOT(nodePtr->left);
        NOT(nodePtr->right);
    }
    else if( nodePtr->text.compare("!") == 0 ){
        nextPtr=nodePtr->right;
        if( nodePtr->parent != NULL ){
            if(nodePtr->parent->left!=NULL && nodePtr->parent->left==nodePtr){
                nodePtr->parent->left=nextPtr;
                nextPtr->parent=nodePtr->parent;
            }
            else if(nodePtr->parent->right!=NULL && nodePtr->parent->right==nodePtr){
                nodePtr->parent->right=nextPtr;
                nextPtr->parent=nodePtr->parent;
            }
            else {
                mexErrMsgIdAndTxt( "MATLAB:mexatexit:invalidNumInputs","NULL pointer is reached in NOT.");
            }            
        }
        else{
            mexErrMsgIdAndTxt( "MATLAB:mexatexit:invalidNumInputs","NULL pointer is reached in NOT.");
        }
        NNF(nextPtr);
    }
    else{
		notNode = new BOOLNODE;
        notNode->text.assign("!");
        notNode->textIndex=-1;
		notNode->nodeIndex = (unsigned int) nodeList.size();
		notNode->left = NULL;
		notNode->processed = true;
		notNode->right = nodePtr;
		notNode->parent = nodePtr->parent;
		if (nodePtr->parent->left != NULL && nodePtr->parent->left == nodePtr)
			nodePtr->parent->left = notNode;
		else if (nodePtr->parent->right != NULL && nodePtr->parent->right == nodePtr)
			nodePtr->parent->right = notNode;
		else
			mexErrMsgIdAndTxt("MATLAB:mexatexit:invalidNumInputs", "NULL pointer is reached in NOT.");
		nodePtr->parent = notNode;
		nodeList.push_back(notNode);
	}
}

void boolTree::NNF(BOOLNODE *nodePtr){
    BOOLNODE *nextPtr,*next2Ptr;
    /*std::string and("&");
    std::string or("|");
    std::string not("!");*/
	if (nodePtr == NULL)
        mexErrMsgIdAndTxt( "MATLAB:mexatexit:invalidNumInputs","NULL pointer is reached in NNF.");
    if( nodePtr->text.compare("|") == 0 || nodePtr->text.compare("&") == 0 ){
        NNF(nodePtr->left);
        NNF(nodePtr->right);
    }
    else if( nodePtr->text.compare("!") == 0 ){
        nextPtr=nodePtr->right;
        if( nextPtr->text.compare("|") == 0 || nextPtr->text.compare("&") == 0 ){
            if ( nodePtr->parent != NULL ){
                if(nodePtr->parent->left!=NULL && nodePtr->parent->left==nodePtr){
                    nodePtr->parent->left=nextPtr;
                    nextPtr->parent=nodePtr->parent;
                }
                else if(nodePtr->parent->right!=NULL && nodePtr->parent->right==nodePtr){
                    nodePtr->parent->right=nextPtr;
                    nextPtr->parent=nodePtr->parent;
                }
                else {
                    mexErrMsgIdAndTxt( "MATLAB:mexatexit:invalidNumInputs","NULL pointer is reached in NNF.");
                }
            }
            else{
                root=nextPtr;
                nextPtr->parent=NULL;
            }
            NOT(nextPtr);
        }
        else if( nextPtr->text.compare("!") == 0 ){
            next2Ptr=nextPtr->right;
            if ( nodePtr->parent != NULL ){
                if(nodePtr->parent->left!=NULL && nodePtr->parent->left==nodePtr){
                    nodePtr->parent->left=next2Ptr;
                    next2Ptr->parent=nodePtr->parent;
                }
                else if(nodePtr->parent->right!=NULL && nodePtr->parent->right==nodePtr){
                    nodePtr->parent->right=next2Ptr;
                    next2Ptr->parent=nodePtr->parent;
                }
                else {
                    mexErrMsgIdAndTxt( "MATLAB:mexatexit:invalidNumInputs","NULL pointer is reached in NNF.");
                }
            }
            else{
                root=next2Ptr;
                next2Ptr->parent=NULL;
            }
            NNF(next2Ptr);
        }
    }
    return;
}

BOOLNODE* boolTree::copyTree(BOOLNODE* copyThis, BOOLNODE* parentNode)
{
	BOOLNODE* newNode;
	if (copyThis != NULL){
		newNode = new BOOLNODE;
		newNode->text.assign(copyThis->text);
		newNode->textIndex = -1;
		newNode->nodeIndex = (unsigned int)nodeList.size();
		newNode->processed = true;
		newNode->left = NULL;
		newNode->right = NULL;
		newNode->parent = parentNode;
		nodeList.push_back(newNode);
		if (copyThis->left != NULL)
			newNode->left = copyTree(copyThis->left,newNode);
		if (copyThis->right != NULL)
			newNode->right = copyTree(copyThis->right,newNode);
	}
	else{
		mexErrMsgIdAndTxt("MATLAB:mexatexit:invalidNumInputs", "NULL pointer is reached in copyTree function.");
	}
	return newNode;
}

void  boolTree::toGraphVizRoot(BOOLNODE *nodePtr,FILE *f){
    if(nodePtr->left!=NULL){
         fprintf(f, "  \"%s(%d)\" -> \"%s(%d)\"\n",nodePtr->text.c_str(),nodePtr->nodeIndex,nodePtr->left->text.c_str(),nodePtr->left->nodeIndex);
         toGraphVizRoot(nodePtr->left,f);
    }
    if(nodePtr->right!=NULL){
         fprintf(f, "  \"%s(%d)\" -> \"%s(%d)\"\n",nodePtr->text.c_str(),nodePtr->nodeIndex,nodePtr->right->text.c_str(),nodePtr->right->nodeIndex);
         toGraphVizRoot(nodePtr->right,f);
    }
}

bool boolTree::checkDNF(BOOLNODE *nodePtr){
    /*std::string and("&");
    std::string or("|");*/
    bool L,R;
    BOOLNODE *OR,*AND,*newAND,*Z,*Y,*X,*newZ;
    if(nodePtr->text.compare("&") == 0 && nodePtr->left->text.compare("|") == 0 ){
    /*       (&)                 (|)
            /   \               /   \
          (|)   (Z)    ==>    (&)   (&*)
          / \                 / \    / \
        (X) (Y)             (X) (Z)(Y) (Z*)
    */
        AND=nodePtr;
        OR=AND->left;
        X=OR->left;
        Y=OR->right;
        Z=AND->right;
        if ( AND->parent!=NULL ){
            if ( AND->parent->left==AND ){
                AND->parent->left=OR;
            }
            else if ( AND->parent->right==AND ){
                AND->parent->right=OR;
            }
            else
                mexErrMsgIdAndTxt("MATLAB:mexatexit:invalidNumInputs", "Incorrect pointer is reached in checkDNF function.");
            OR->parent=AND->parent;
        }
        else{
            root=OR;
            OR->parent=NULL;
        }
        OR->left=AND;
        AND->parent=OR;
        AND->left=X;
        X->parent=AND;
        AND->right=Z;
        Z->parent=AND;
        newZ=copyTree(Z,NULL);
        newAND= new BOOLNODE;
   		newAND->text.assign("&");
		newAND->textIndex = -1;
		newAND->nodeIndex = (unsigned int)nodeList.size();
		newAND->processed = true;
		newAND->left = Y;
        Y->parent=newAND;
		newAND->right = newZ;
        newZ->parent=newAND;
		newAND->parent = OR;
        OR->right=newAND;
		nodeList.push_back(newAND);

        return false;
    }
    else if(nodePtr->text.compare("&") == 0 && nodePtr->right->text.compare("|") == 0 ){
    /*       (&)                 (|)
            /   \               /   \
          (Z)   (|)    ==>    (&)   (&*)
                / \           / \    / \
              (X) (Y)       (Z) (X)(Z*)(Y)
    */
        AND=nodePtr;
        OR=AND->right;
        X=OR->left;
        Y=OR->right;
        Z=AND->left;
        if ( AND->parent!=NULL ){
            if ( AND->parent->left==AND ){
                AND->parent->left=OR;
            }
            else if ( AND->parent->right==AND ){
                AND->parent->right=OR;
            }
            else
                mexErrMsgIdAndTxt("MATLAB:mexatexit:invalidNumInputs", "Incorrect pointer is reached in checkDNF function.");
            OR->parent=AND->parent;
        }
        else{
            root=OR;
            OR->parent=NULL;
        }
        OR->left=AND;
        AND->parent=OR;
        AND->left=Z;
        Z->parent=AND;
        AND->right=X;
        X->parent=AND;
        newZ=copyTree(Z,NULL);
        newAND= new BOOLNODE;
   		newAND->text.assign("&");
		newAND->textIndex = -1;
		newAND->nodeIndex = (unsigned int)nodeList.size();
		newAND->processed = true;
		newAND->left = newZ;
        newZ->parent=newAND;
		newAND->right = Y;
        Y->parent=newAND;
		newAND->parent = OR;
        OR->right=newAND;
		nodeList.push_back(newAND);
        return false;
    }
    else if(nodePtr->text.compare("&") == 0 || nodePtr->text.compare("|") == 0){
        L=checkDNF(nodePtr->left);
        R=checkDNF(nodePtr->right);
        return (L && R);
    }
    else
        return true;
}

void boolTree::countConjuncts(BOOLNODE *nodePtr){
    /*std::string and("&");
    std::string or("|");*/
    if(nodePtr->text.compare("|") == 0 ){
        if( nodePtr->left->text.compare("|") == 0 )
            countConjuncts(nodePtr->left);
        else 
            conjuncts.push_back(nodePtr->left);
        if( nodePtr->right->text.compare("|") == 0 )
            countConjuncts(nodePtr->right);
        else 
            conjuncts.push_back(nodePtr->right);        
    }
    else{
        return;
    }
}

void boolTree::countLiterals(BOOLNODE *nodePtr){
    /*std::string and("&");*/
    if(nodePtr->text.compare("&") == 0 ){
        if( nodePtr->left->text.compare("&") == 0 )
            countLiterals(nodePtr->left);
        else 
            literals.push_back(nodePtr->left);
        if( nodePtr->right->text.compare("&") == 0 )
            countLiterals(nodePtr->right);
        else 
            literals.push_back(nodePtr->right);        
    }
    else{
		literals.push_back(nodePtr);
    }
}

void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
    char *str;
    unsigned int i,j;
    boolTree *formula;
    std::vector<std::string> token;
    /*std::string or("|");
    std::string not("!");*/

    formula = new boolTree;
    /* Check for proper number of input and output arguments */
    if (nrhs != 1) {
        mexErrMsgIdAndTxt( "MATLAB:mexatexit:invalidNumInputs",
                "One input argument required.");
    }
    if (nlhs > 1){
        mexErrMsgIdAndTxt( "MATLAB:mexatexit:maxlhs",
                "Too many output arguments.");
    }
    
    /* Check to be sure input is of type char */
    if (!(mxIsChar(prhs[0]))){
        mexErrMsgIdAndTxt( "MATLAB:mexatexit:inputNotString",
                "Input must be of type string.\n.");
    }
    
    /* The user passes a string in prhs[0]; write the string
     * to the data file. NOTE: you must free str after it is used */
    str=mxArrayToString(prhs[0]);
    mexPrintf("--------------\n%s=%d\n",str,strlen(str));
    formula->textFormula=str;
    token=split((const char *)str);
    formula->tokenFormula=token;
    formula->createNodes();
    formula->checkParan();
    formula->root=formula->createBooleanTree(0,(unsigned int)token.size()-1);
    formula->NNF(formula->root);
    while(!formula->checkDNF(formula->root));
    
    mexPrintf("formula is %s DNF \n",(formula->checkDNF(formula->root)?"":"NOT"));
    if( formula->root->text.compare("|") == 0 ){
        formula->countConjuncts(formula->root);
    }
    else{
        formula->conjuncts.push_back(formula->root);
    }
    formula->textNNF=" ";
    for(i=0;i<formula->conjuncts.size();i++){
        formula->textNNF+=" (";
        formula->literals.erase(formula->literals.begin(),formula->literals.end());
        formula->countLiterals(formula->conjuncts[i]);
        for(j=0;j<formula->literals.size();j++){
            if(formula->literals[j]->text.compare("!") == 0 ){
                formula->textNNF+=" ! ";
                formula->textNNF+=formula->literals[j]->right->text;
            }
            else{
                formula->textNNF+=" ";
                formula->textNNF+=formula->literals[j]->text;
            }
            if(j<formula->literals.size()-1)
                formula->textNNF+=" &";      
        }
        formula->textNNF+=" )";
      if(i<formula->conjuncts.size()-1)
            formula->textNNF+=" |";
    }
    plhs[0] = mxCreateString(formula->textNNF.c_str());
    mxFree(str);
    delete formula;
    return;
}
