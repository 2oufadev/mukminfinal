const functions = require("firebase-functions");
const admin = require('firebase-admin');
const { snapshotConstructor } = require("firebase-functions/v1/firestore");
admin.initializeApp(functions.config().functions);

exports.userRedeemed=functions.firestore.document('SponsorsList/{sponsorId}/RedeemedUsers/{user}').onCreate(
   async (snapshot,context)=>{
     var ownerEmailVar=await admin.firestore().doc('SponsorsList/'+context.params.sponsorId).get();

     var ownerEmail=ownerEmailVar.data().userEmail;
     console.log(ownerEmail);
     var query = await admin.firestore().collection('Users').where('email', '==', ownerEmail).get().then(result => {
      result.forEach(async (doc) => {
           console.log('~~~~~~~~~~~~~~~~');
          
          console.log( doc.data());
          var ownerToken=doc.data().token;
          var userToken = snapshot.data().userToken;
       const payload = {
        notification: {
          title: 'New Coupon Redeem',
          body:snapshot.data().username+' has redeemed your coupon',
         
          click_action: `FLUTTER_NOTIFICATION_CLICK`,
        }
      };

      const payload2 = {
        notification: {
          title: 'Congratulations!',
          body:'Your subscription have been Success and will Expire at '+snapshot.data().endDate +' based on Sponsor',
         
          click_action: `FLUTTER_NOTIFICATION_CLICK`,
        }
      };

      console.log('~~~~~~~~~~~~~~~~');
      console.log(ownerToken);
      console.log('~~~~~~~~~~~~~~~~');
      console.log(userToken);
      console.log('~~~~~~~~~~~~~~~~');
      console.log(snapshot.data().username);
      console.log('~~~~~~~~~~~~~~~~');
      console.log(snapshot.data().endDate);
       const response=await admin.messaging().sendToDevice([ownerToken],payload);
       const response2=await admin.messaging().sendToDevice([userToken],payload2);
       console.log('~~~~~~~~~~~~~~~~');
       console.log(response);
       console.log(response.results[0].error);
       console.log('~~~~~~~~~~~~~~~~');
       console.log(response2);
       console.log(response2.results[0].error);

          console.log('~~~~~~~~~~~~~~~~');
      });
  });
  
    
    //  console.log(query);
    //  console.log('~~~~~~~~~~~~~~~~');
    //  console.log(query[0]);
     
    //  console.log('~~~~~~~~~~~~~~~~');
    //  console.log(query[0].data());
    //  console.log('~~~~~~~~~~~~~~~~');

     
     

     


    

    }
);

exports.userRedeem=functions.firestore.document('SponsorsList/{sponsorId}').onUpdate(
  async (change,context)=>{

    const newValue = change.after.data();

    // ...or the previous value before this update
    const previousValue = change.before.data();

    if(newValue.redeemedUsers!= previousValue.redeemedUsers ){
      var ownerEmail=previousValue.userEmail;
      console.log(ownerEmail);

      var usersList=newValue.redeemedUsers;
      var user=usersList[usersList.length - 1];
     


    var query = await admin.firestore().collection('Users').where('email', '==', ownerEmail).get().then(result => {
     result.forEach(async (doc) => {
          console.log('~~~~~~~~~~~~~~~~');
         
         console.log( doc.data());
         var ownerToken=doc.data().token;
         var userToken = user.userToken;
      const payload = {
       data: {
         title: 'New Coupon Redeem',
         body:user.username+' has redeemed your coupon',
         sound : "default",
         click_action: `FLUTTER_NOTIFICATION_CLICK`,
       }
     };

     const payload2 = {
       data: {
         title: 'Congratulations!',
         body:'Your subscription have been Success and will Expire at '+user.endDate +' based on Sponsor',
         sound : "default",
         click_action: `FLUTTER_NOTIFICATION_CLICK`,
       }


     };

     console.log('~~~~~~~~~~~~~~~~');
     console.log(ownerToken);
     console.log('~~~~~~~~~~~~~~~~');
     console.log(userToken);
     console.log('~~~~~~~~~~~~~~~~');
     
      const response=await admin.messaging().sendToDevice([ownerToken],payload);
      const response2=await admin.messaging().sendToDevice([userToken],payload2);
      console.log('~~~~~~~~~~~~~~~~');
      console.log(response);
      console.log(response.results[0].error);
      console.log('~~~~~~~~~~~~~~~~');
      console.log(response2);
      console.log(response2.results[0].error);

         console.log('~~~~~~~~~~~~~~~~');
     });
 });
    }
    
 
   
   //  console.log(query);
   //  console.log('~~~~~~~~~~~~~~~~');
   //  console.log(query[0]);
    
   //  console.log('~~~~~~~~~~~~~~~~');
   //  console.log(query[0].data());
   //  console.log('~~~~~~~~~~~~~~~~');

    
    

    


   

   }
);

exports.userAddList=functions.firestore.document('SponsorsList/{sponsorId}').onCreate(
  async (snapshot,context)=>{
    var userEmail=snapshot.data().userEmail;


    var query = await admin.firestore().collection('Users').where('email', '==', userEmail).get().then(result => {
     result.forEach(async (doc) => {
          console.log('~~~~~~~~~~~~~~~~');
         
         console.log( doc.data());
         await admin.firestore().collection('Users').doc(doc.data().UID).update({sponsorsList: admin.firestore.FieldValue.arrayUnion(context.params.sponsorId)});

         console.log('~~~~~~~~~~~~~~~~');
     });
 });
 
   
   //  console.log(query);
   //  console.log('~~~~~~~~~~~~~~~~');
   //  console.log(query[0]);
    
   //  console.log('~~~~~~~~~~~~~~~~');
   //  console.log(query[0].data());
   //  console.log('~~~~~~~~~~~~~~~~');

    
    

    


   

   }
);

// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
