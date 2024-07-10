# -*- coding: utf-8 -*-
"""
Created on Tue Jun 27 22:26:54 2023

@author: HP
"""
"""
根据保存在txt文件中的rs号（每行一个号）从NCBI中查询SNP所在基因；
结果以csv形式保存
"""
import urllib
import os

def getRsLst(fn):
    rslst = []
    with open(fn) as f:
        for l in f.readlines():
            rslst.append(l.strip())
            
    return rslst

def getGenes(rslst):
# 网页格式：
#Gene:</dt><dd><span class="snpsum_hgvs">POLD4 (<a href="/variation/view/?q=rs6560"><span>Varview</span></a>),
# LOC100130987 (<a href="/variation/view/?q=rs6560"><span>Varview</span></a>)</span>
#</dd><dt>Functional Consequence: 
    res = {}
    for rs in rslst:
        url = 'https://www.ncbi.nlm.nih.gov/snp/?term=%s' %rs
        page = urllib.request.urlopen(url).read().decode('utf-8')
    
        s1=page.find('Gene:')
        s2 = page.find('Functional Consequence:')
        fs = page[s1:s2]   # 包含基因名的字符串，可能包含多个基因
    #    提取基因名
        gene = []
        while True:
            s1 = fs.find('(<a href=')-1
            if s1 < 0:
                break
                
            i = 1
            isOk = False
            while (s1-i) >= 0:
                if not (fs[s1-i].isalpha() or fs[s1-i].isdigit()):
                    isOk = True
                    break
                i = i + 1
                
            if isOk:
                gene.append(fs[s1-i+1:s1].strip())
              
            fs = fs[s1+9:-1]
        
        res[rs] = gene
        print('.',end='')
        
    print('')
    return res
     
if __name__== "__main__" :
    dirCAM = os.path.join(os.getcwd(),'BDOK','GradCAM');        # GradCAM输出目录
    for fn in range(1,5):
        rsFn = os.path.join(dirCAM,'SNPBDnorpt%d.txt' % fn)     #rs文件名
        resFn = os.path.join(dirCAM,'Genes%d.csv' % fn)         # 结果文件名
        rslst = getRsLst(os.path.join(dirCAM,rsFn))
        
        if len(rslst) == 0:
            print('%s未找到SNP' % rsFn)
        else:
            genes = getGenes(rslst)
        
        if len(genes) == 0:
            print('%s未检索到任何基因' % rsFn)
        else:
            f = open(os.path.join(dirCAM,resFn),'w')
            f.write('rsID,Genes\n')   #表头
            for key in genes:
                f.write('%s,' % key)
                lk = len(genes[key])
                if lk > 0:
                    i = 1
                    for ln in genes[key]:
                        if i == lk:
                            f.write('%s\n' % ln)
                        else:
                            f.write('%s,' % ln)
                        i = i + 1
                        
            f.close()
                
    
    
    
    
    
    
    
    