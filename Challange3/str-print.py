import json

def getValue(obj,key):
    jobj = json.loads(str(obj).replace("'", "\""))
    
    keyfrmt="jobj['"+key.replace("/", "']['")+"']"
    retval=eval(keyfrmt)
    return retval
    
    
object1={"a":{"b":{"c":"d"}}}
key="a/b/c"

retv=getValue(object1,key)
print(retv)