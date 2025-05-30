const PersonalInfo = require('../models/personalInfoSchema');

const security = async (req, res) => {
   console.log("security")
   try {
    const user = await PersonalInfo.findOne({name: req.params.name})
    const securityPin= req.body.securityPin;
     // Debugging
    console.log(securityPin)
    if(user.securityPin==securityPin){
        console.log("pin matched")
        return res.send({isValid: true})
    }else{
        return res.send({isValid: false});
    }}catch(err){
        res.status(500).send({ message: 'Server error' });
    }

}
module.exports = { security };