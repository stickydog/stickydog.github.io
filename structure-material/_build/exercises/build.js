const fs=require('fs'),path=require('path'),katex=require('katex');
const dir=path.join(__dirname,'src');
let content=fs.readdirSync(dir).filter(f=>f.endsWith('.html')).sort().map(f=>fs.readFileSync(path.join(dir,f),'utf8')).join('\n');
let n=0,errs=[];
function render(tex,display){n++;try{return katex.renderToString(tex,{displayMode:display,throwOnError:true,strict:'ignore',output:'html'})}catch(e){errs.push(e.message+' :: '+tex.slice(0,80));return '<span style="color:red">'+tex+'</span>'}}
// protect <pre> blocks
const pres=[];content=content.replace(/<pre[\s\S]*?<\/pre>/g,m=>{pres.push(m);return `@@PRE${pres.length-1}@@`});
content=content.replace(/\\\[([\s\S]+?)\\\]/g,(m,t)=>render(t.trim(),true));
content=content.replace(/\\\(([\s\S]+?)\\\)/g,(m,t)=>render(t.trim(),false));
content=content.replace(/@@PRE(\d+)@@/g,(m,i)=>pres[+i]);
if(errs.length){console.error(errs.join('\n'));process.exit(1)}
// nav + cards
const groups={t:'课堂习题 Tutorials',h:'课后作业 Home Exercises',e:'模拟考试 Trial Exam'};
let nav='',cards='',lastg='';
const secRe=/<section class="set" id="([^"]+)" data-short="([^"]+)">([\s\S]*?)<\/section>/g;let m;
const strip=s=>s.replace(/<span class="katex">[\s\S]*?<\/annotation><\/semantics><\/math><\/span>/g,'').replace(/<[^>]+>/g,'').replace(/\s+/g,' ').trim();
const ann=s=>s.replace(/<span class="katex"><span class="katex-html"[\s\S]*?<\/span><\/span><\/span>/g,'');
while((m=secRe.exec(content))){const [_,id,short,body]=m;
  const g=id[0]==='t'?'t':id[0]==='h'?'h':'e'; if(g!==lastg){nav+=`<li class="grp">${groups[g]}</li>`;lastg=g}
  const tm=/<h2 class="set-title"><span class="set-num">[^<]*<\/span>([\s\S]*?)<span class="set-src">/.exec(body);
  const title=tm[1].trim();
  let sub='';const tr=/<article class="task" id="([^"]+)">\s*<h3><span class="tno">([\s\S]*?)<\/span>([\s\S]*?)<\/h3>/g;let a,cnt=0;
  while((a=tr.exec(body))){cnt++;sub+=`<li><a href="#${a[1]}">${a[2].replace(/<[^>]+>/g,'')} · ${a[3].replace(/<span class="katex">[\s\S]*$/,'').trim()}</a></li>`}
  nav+=`<li><a href="#${id}">${short}</a><ul>${sub}</ul></li>`;
  cards+=`<a href="#${id}"><b>${short}</b>${title}<br><span>${cnt} 题</span></a>`;
}
// katex css with woff2 fonts inlined
const kd=path.join(__dirname,'node_modules/katex/dist');
let css=fs.readFileSync(path.join(kd,'katex.min.css'),'utf8');
css=css.replace(/src:url\(fonts\/([^)]+\.woff2)\) format\("woff2"\)(,url\([^)]+\) format\("[^"]+"\))*/g,(mm,f)=>`src:url(data:font/woff2;base64,${fs.readFileSync(path.join(kd,'fonts',f)).toString('base64')}) format("woff2")`);
let out=fs.readFileSync(path.join(__dirname,'template.html'),'utf8').replace('/*KATEX_CSS*/',()=>css).replace('<!--NAV-->',()=>nav).replace('<!--CARDS-->',()=>cards).replace('<!--CONTENT-->',()=>content);
fs.writeFileSync(process.argv[2],out);console.log('formulas',n,'bytes',out.length);
