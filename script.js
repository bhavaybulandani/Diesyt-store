const e=document.getElementById('eyes'),l=document.getElementById('logo'),f=document.getElementById('fill'),s=document.getElementById('status');
const msgs=['INITIALIZING...','CONNECTING...','VERIFYING...','LOADING STORE...','ACCESS GRANTED'];
setTimeout(()=>{e.style.transition='1.2s';e.style.opacity='0';},2500);
setTimeout(()=>{l.style.transition='1.2s';l.style.opacity='1';},3200);
let i=0,p=0;
setInterval(()=>{if(i<msgs.length)s.textContent=msgs[i++]},1700);
let t=setInterval(()=>{p++;f.style.width=p+'%';if(p>=100){clearInterval(t);s.textContent='ENTERING DIESYT STORE...';}},80);
