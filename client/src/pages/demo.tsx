import React from 'react';
import Container from '@/components/Container';
import GradientText from '@/components/GradientText';
import FantasyHeading from '@/components/FantasyHeading';

const DemoPage = () => {
  return (
    <Container size="lg" className="p-8">
      <FantasyHeading as="h1" size="2xl" className="mb-4">
        <GradientText variant="fantasy">
          AFL Fantasy Component Showcase
        </GradientText>
      </FantasyHeading>
      
      <FantasyHeading as="h2" size="lg" className="mb-2">
        Container Component
      </FantasyHeading>
      <p className="mb-6">
        This container centers its content and allows you to adjust the max-width according to the size prop.
      </p>
      
      <FantasyHeading as="h2" size="lg" className="mb-2">
        GradientText Component
      </FantasyHeading>
      <p className="mb-6">
        Apply beautiful gradient effects to your text spans effortlessly.
      </p>
      
      <FantasyHeading as="h2" size="lg" className="mb-2">
        FantasyHeading Component
      </FantasyHeading>
      <p className="mb-6">
        Use semantic headings with a touch of fantasy styling.
      </p>
    </Container>
  );
};

export default DemoPage;
