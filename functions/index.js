/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */



const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");


const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { Storage } = require('@google-cloud/storage');
const { GLTFExporter } = require('three/examples/jsm/exporters/GLTFExporter.js');
const { Scene, MeshBasicMaterial, PlaneGeometry, TextureLoader, Mesh } = require('three');
const { createCanvas } = require('canvas');

admin.initializeApp();
const storage = new Storage();

exports.convertPngToGltf = functions.https.onCall(async (data, context) => {
    const fileName = data.fileName;
    const bucket = storage.bucket(admin.storage().bucket().name);
    const filePath = `uploads/${fileName}`;
    const tempFilePath = `/tmp/${fileName}`;

    // Download the PNG file
    await bucket.file(filePath).download({ destination: tempFilePath });

    // Create a 3D scene and convert it to GLTF
    const canvas = createCanvas(512, 512);
    const context = canvas.getContext('2d');
    const textureLoader = new TextureLoader();
    const image = await loadImage(tempFilePath, context);

    const scene = new Scene();
    const texture = textureLoader.load(image);

    const planeGeometry = new PlaneGeometry(1, 1);
    const material = new MeshBasicMaterial({ map: texture });
    const plane = new Mesh(planeGeometry, material);

    scene.add(plane);

    // Export to GLTF
    const exporter = new GLTFExporter();
    exporter.parse(scene, async (result) => {
        const gltfData = JSON.stringify(result);
        const gltfFilePath = filePath.replace('.png', '.gltf');

        // Upload GLTF file
        const file = bucket.file(gltfFilePath);
        await file.save(gltfData);
        console.log(`GLTF file created at: ${gltfFilePath}`);
    });
});

// Helper function to load the image
function loadImage(filePath, context) {
    return new Promise((resolve, reject) => {
        const img = new Image();
        img.onload = () => {
            context.drawImage(img, 0, 0);
            resolve(img.src);
        };
        img.onerror = (err) => reject(err);
        img.src = filePath;
    });
}


// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
