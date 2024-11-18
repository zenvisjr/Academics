let baseURL = 'https://api.spotify.com';

let client_id = '687c7fdc0f63489586cc29a162535457';// Username
let client_secret = '86296c2549134602aafd3ca45ccda59e'; // Password

// async function search(token, query) {
//   let url = `https://api.spotify.com/v1/search`;
//   const params = new URLSearchParams({
//     q: query,
//     market: 'ES',
//     limit: '10',
//     offset: '5'
//   });
//   url += `?${params.toString()}`;
//   headers = {
//     Authorization: `${token.token_type} ${token.access_token}`
//   };
  

//   try {
//     const res = await fetch(url, { method: 'GET', headers: headers });
//     if (res.ok) {
//       const data = await res.json();

//       const firstTrack = data.tracks.items[0];  // Assuming you want the first result

//       let originalTrackUrl = firstTrack.external_urls.spotify;
//       let embeddableTrackUrl = originalTrackUrl.replace('track', 'embed/track') + "?utm_source=generator";
//       document.getElementById("spotify-link").setAttribute('src', embeddableTrackUrl);

      
//     } else {
//       console.log("Failed to fetch data: ", res.status, res.statusText);
//     }
//   } catch (err) {
//     console.log('Error fetching data:', err.message);
//   }
// }

// document.getElementById('search-form').addEventListener('submit', function(e) {
//   e.preventDefault();
//   const query = document.getElementById('query').value;
//   search(token, query); 
// });


async function track(token) {
  const url = `https://api.spotify.com/v1/tracks/5kKloaKFvAuDNFi8m52hxy`;
  headers = {
    Authorization: `${token.token_type} ${token.access_token}`
  };

  try {
    const res = await fetch(url, { method: 'GET', headers: headers });
    if (res.ok) {
      const data = await res.json();
      console.log("Showing Track Data\n");
      console.log("Track Name:", data.name);
      console.log("Artist URI:", data.artists[0].name);
      console.log("Release Date:", data.album.release_date);
      console.log("Album_type:", data.album.album_type);
      console.log("Link to music:", data.album.external_urls.spotify);
      console.log("Duration:", (data.duration_ms / 60000).toFixed(2) + " mins");
      console.log("Explicit:", data.explicit ? "Yes" : "No");
      console.log("Popularity:", data.popularity);
      console.log('\n');

            document.getElementById("track-name").innerText = data.name;
      document.getElementById("artist-name").innerText = data.artists[0].name;
      document.getElementById("album-name").innerText = data.album.name;
      document.getElementById("album-type").innerText = data.album.album_type;
      document.getElementById("release-date").innerText = data.album.release_date;
      document.getElementById("duration").innerText = (data.duration_ms / 60000).toFixed(2) + " mins";
      document.getElementById("explicit").innerText = data.explicit ? "Yes" : "No";
      document.getElementById("popularity").innerText = data.popularity;
      // document.getElementById("spotify-link").setAttribute("href", data.album.external_urls.spotify);
      // let originalPlaylistUrl = data.album.external_urls.spotify;  
      // let embeddablePlaylistUrl = originalPlaylistUrl.replace('playlist', 'embed/playlist') + "?utm_source=generator";
      // document.getElementById("spotify-link").setAttribute('src', embeddablePlaylistUrl);

      let originalTrackUrl = data.album.external_urls.spotify;
      let embeddableTrackUrl = originalTrackUrl.replace('album', 'embed/album') + "?utm_source=generator";
      document.getElementById("spotify-link").setAttribute('src', embeddableTrackUrl);

      
    } else {
      console.log("Failed to fetch data: ", res.status, res.statusText);
    }
  } catch (err) {
    console.log('Error fetching data:', err.message);
  }
}


async function playlist(token) {
  let url = `https://api.spotify.com/v1/playlists/6YIVcPNwn8b4INaUQOgrh7?si=55cc504b6f624cf4`;
  const params = new URLSearchParams({
    market: 'ES',
    limit: '10',
    offset: '5'
  });
  url += `&${params.toString()}`;

  const headers = {
    Authorization: `${token.token_type} ${token.access_token}`
  };

  try {
    const res = await fetch(url, { method: 'GET', headers: headers });
    if (res.ok) {
      const data = await res.json();
      console.log(data);
      console.log("Showing Playlist Data\n");
      console.log("playlist name: ", data.name);
      console.log("total: ", data.tracks.total);
      console.log("img src: ", data.images[0].url);
      console.log("Description: ", data.description);
      console.log("Owner: ", data.owner.display_name);
      console.log("Followers: ", data.followers.total);
      console.log("Public: ", data.public);
      console.log("link to playlist: ", data.external_urls.spotify);

      console.log('\n');

      // Accessing the 'items' array and slicing it to get the first 3 items
      const firsThreeItems = data.tracks.items.slice(0, 3);
      
      // Iterating through the first 3 items
      firsThreeItems.forEach((item, index) => {
        console.log(`--- Song ${index + 1} ---`);
        console.log("Track Name:", item.track.name);
        console.log("Artist:", item.track.artists[0].name);  // Assuming at least one artist exists
        console.log("Album:", item.track.album.name);
        console.log("Release Date:", item.track.album.release_date);
        console.log("Duration:", (item.track.duration_ms / 60000).toFixed(2) + " mins");
        console.log("Explicit:", item.track.explicit ? "Yes" : "No");
        console.log("Popularity:", item.track.popularity);
        console.log("Spotify URL:", item.track.external_urls.spotify);
        console.log("\n");
      });
    // document.getElementById("playlistname").innerText = data.name;

    document.getElementById("playlist-name").innerText = data.name;
    document.getElementById("playlist-total-tracks").innerText = data.tracks.total;
    document.getElementById("playlist-image").src = data.images[0].url;
    document.getElementById("playlist-description").innerText = data.description;
    document.getElementById("playlist-owner").innerText = data.owner.display_name;
    document.getElementById("playlist-followers").innerText = data.followers.total;
    document.getElementById("playlist-public").innerText = data.public ? "Yes" : "No";
    // document.getElementById("playlist-spotify-link").href = data.external_urls.spotify;

    let originalPlaylistUrl = data.external_urls.spotify;  
    let embeddablePlaylistUrl = originalPlaylistUrl.replace('playlist', 'embed/playlist');
    document.getElementById("playlist-spotify-link").setAttribute('src', embeddablePlaylistUrl);



    // document.getElementById("playlistname").innerText = data.name;
    const firstThreeItems = data.tracks.items.slice(0, 3);

    firstThreeItems.forEach((item, index) => {
      // Assuming your HTML div IDs are "song-1", "song-2", "song-3" etc.
      const songDiv = document.getElementById(`song-${index + 1}`);
      

      if (songDiv) {
        songDiv.querySelector('.song-name').textContent = item.track.name;
        songDiv.querySelector('.song-artist').textContent = item.track.artists[0].name;
        songDiv.querySelector('.song-album').textContent = item.track.album.name;
        songDiv.querySelector('.song-release-date').textContent = item.track.album.release_date;
        songDiv.querySelector('.song-duration').textContent = (item.track.duration_ms / 60000).toFixed(2) + ' mins';
        songDiv.querySelector('.song-popularity').textContent = item.track.popularity;
        songDiv.querySelector('.song-explict').textContent = item.track.explicit ? 'Yes' : 'No';
        // songDiv.querySelector('#spotify-link').href = item.track.external_urls.spotify;
        let originalUrl = item.track.external_urls.spotify;  // 
        let embeddableUrl = originalUrl.replace('track', 'embed/track') + "?utm_source=generator";
        songDiv.querySelector('#spotify-link').setAttribute('src', embeddableUrl);
      }
    });

    // document.querySelector('.song-name').innerText = playlistName;
    document.getElementById("playname").innerText = data.name;
      
    } else {
      console.log("Failed to fetch data: ", res.status, res.statusText);
    }
  } catch (err) {
    console.log('Error fetching data:', err.message);
  }
}


/*********************************showing artist top track*****************************************/


async function artist_top_track(token) {
  let url = new URL('https://api.spotify.com/v1/artists/7vk5e3vY1uw9plTHJAMwjN/top-tracks');
  url.searchParams.append('market', 'ES');

  const headers = {
    Authorization: `${token.token_type} ${token.access_token}`
  };

  try {
    const res = await fetch(url.toString(), { method: 'GET', headers: headers });
    if (res.ok) {
      const data = await res.json();
      console.log(data);
      console.log("Showing artist top track\n");
         
      const topTracks = data.tracks.slice(0, 3);  // Get the first 3 tracks
      
      topTracks.forEach((track, index) => {
      console.log(`--- Track ${index + 1} ---`);

      console.log("Track Name:", track.name);

      // Log album details
      console.log("Album Name:", track.album.name);
      console.log("Album Release Date:", track.album.release_date);
    
      // Log artist details
      const artistNames = track.artists.map(artist => artist.name).join(', ');
      console.log("Artists:", artistNames);

      console.log("Preview Song: ", track.preview_url);

      console.log("Duration:", (track.duration_ms / 60000).toFixed(2) + " mins");
      console.log("Explicit:", track.explicit ? "Yes" : "No");
      console.log("Popularity:", track.popularity);
      console.log("Spotify URL:", track.external_urls.spotify);

      console.log("\n");
    });
      console.log("\n");


      topTracks.forEach((track, index) => {
        // Convert track duration from ms to minutes
        const durationMins = (track.duration_ms / 60000).toFixed(2) + " mins";
      
        // Concatenate artist names
        const artistNames = track.artists.map(artist => artist.name).join(', ');
      
        // Update HTML elements
        document.getElementById(`track${index+1}-name`).textContent = track.name;
        document.getElementById(`track${index+1}-album`).textContent = track.album.name;
        document.getElementById(`track${index+1}-release-date`).textContent = track.album.release_date;
        document.getElementById(`track${index+1}-artists`).textContent = artistNames;
        document.getElementById(`track${index+1}-duration`).textContent = durationMins;
        document.getElementById(`track${index+1}-explicit`).textContent = track.explicit ? "Yes" : "No";
        document.getElementById(`track${index+1}-popularity`).textContent = track.popularity;
        // document.getElementById(`track${index+1}-audio-source`).src = track.preview_url;
        // Reload the audio element to apply changes
        // const audioElement = document.getElementById(`track${index+1}-audio-preview`);
        // audioElement.load();
        // document.getElementById(`track${index+1}-url`).href = track.external_urls.spotify;
        let originalUrl = track.external_urls.spotify;  // 
        let embeddableUrl = originalUrl.replace('track', 'embed/track') + "?utm_source=generator";
        document.getElementById(`track${index+1}-url`).setAttribute('src', embeddableUrl);

      });
      
    





    } else {
      console.log("Failed to fetch data: ", res.status, res.statusText);
    }
  } catch (err) {
    console.log('Error fetching data:', err.message);
  }
}

/***********************************************current user******************************** */
// Assuming 'fetch' is globally available or imported

// async function currentuser(token) {
//   // Validate token object to ensure it has the necessary properties
//   if (!token || !token.token_type || !token.access_token) {
//     console.log('Invalid token object');
//     return;
//   }

//   const url = `https://api.spotify.com/v1/me`;
//   const headers = {
//     Authorization: `${token.token_type} ${token.access_token}`
//   };

//   console.log("URL: ", url);
//   console.log("Headers: ", headers);

//   try {
//     const res = await fetch(url, { method: 'GET', headers: headers });
//     if (res.ok) {
//       const data = await res.json();
//       // Uncomment the following lines to process the data
//       // console.log("Showing Track Data\n");
//       // console.log("Track Name:", data.name);
//       // console.log("Artist URI:", data.artists[0].name);
//       // console.log("Release Date:", data.album.release_date);
//       // console.log("Album_type:", data.album.album_type);
//       // console.log("Link to music:", data.album.external_urls.spotify);
//       // console.log("Duration:", (data.duration_ms / 60000).toFixed(2) + " mins");
//       // console.log("Explicit:", data.explicit ? "Yes" : "No");
//       // console.log("Popularity:", data.popularity);
//       console.log('\n');
//     } else {
//       console.log("Failed to fetch data: ", res.status, res.statusText);
//     }
//   } catch (err) {
//     console.log('Error fetching data:', err.message);
//   }
// }



















async function getAuthToken() {
  console.log("chat mc")

  const auth = 'Basic ' + btoa(client_id + ':' + client_secret);


  // const auth = 'Basic ' + (new Buffer.from(client_id + ':' + client_secret).toString('base64'));

  const url = 'https://accounts.spotify.com/api/token';
  const headers = {
    'Authorization': auth,
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  const body = new URLSearchParams();
  body.append('grant_type', 'client_credentials');

  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: headers,
      body: body
    });

    if (response.ok) {
      const data = await response.json();
      console.log(data);  // Here, data.access_token is the access token
      await track(data);
      await playlist(data);
      await artist_top_track(data);
      await currentuser(data);
    } else {
      console.log('Failed to fetch access token:', response.status, response.statusText);
    }
  } catch (error) {
    console.error('Error fetching data:', error);
  }
}

getAuthToken();
