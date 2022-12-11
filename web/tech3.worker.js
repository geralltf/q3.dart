onmessage = function(params) 
{
    console.log('hi from worker');
    
    //postMessage({type: 'worker', params: params },[params]);
    
    //onq3message(msg);
    
    
};

//function postMessage2(params, replay){
//	postMessage({type: 'worker' }, params);
//}